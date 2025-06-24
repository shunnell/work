data "aws_caller_identity" "current" {}

module "gitlab_runner" {
  source = "../../helm"

  release_name  = local.runner_fleet_name
  repository    = "https://charts.gitlab.io"
  chart         = "gitlab-runner"
  namespace     = kubernetes_namespace.fleet_namespace.metadata[0].name
  chart_version = "0.77.3"
  # The below invocation should be complete and declarative, so things can be fully replaced:
  force_update = true
  atomic       = true
  # Ref: https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/main/values.yaml
  set_sensitive = {
    "runnerToken" = local.join_token
  }
  values = [
    <<-YAML
    image:
      # Default registry used to bootstrap runner pods (not the same as what's used in jobs):
      registry: ${var.runner_image_registry_root}
      image: platform/docker/gitlab/gitlab-runner
      tag: alpine-v{{.Chart.AppVersion}}
    concurrent: ${var.concurrency_jobs_per_pod}
    replicas: ${var.concurrency_pods}
    gitlabUrl: "https://${var.gitlab_mothership_domain}/"
    certsSecretName: "${kubernetes_secret.gitlab_certificate.metadata[0].name}"
    serviceAccount:
      name: "${module.runner_iam_role.service_account_name}"
      create: false
    rbac:
      create: true
      rules:  # Modifications from chart default values indicated below in comments:
        - resources: ["events"]
          verbs: [${local.rbac_read}]
        # Removed because runners should stay in their namespaces
        # - resources: ["namespaces"]
        #   verbs: ["create", "delete"]
        - resources: ["pods"]
          verbs: [${local.rbac_read},${local.rbac_write}]
        - apiGroups: [""]
          resources: ["pods/attach","pods/exec"]
          verbs: [${local.rbac_read},${local.rbac_write}]
        - apiGroups: [""]
          resources: ["pods/log"]
          verbs: [${local.rbac_read}]
        - apiGroups: [""]  # Added API group
          resources: ["secrets"]
          verbs: [${local.rbac_read},${local.rbac_write}]
        - resources: ["serviceaccounts"]
          verbs: [${local.rbac_read}]
        # Removed because we're not enabling the runner shell/debug service yet; if we do, uncomment.
        # - resources: ["services"]
        #   verbs: ["create","get","list"]
    runners:
      config: |
        [[runners]]
          builds_dir = "${local.builds_dir}"
          # 'FF_USE_ADVANCED_POD_SPEC_CONFIGURATION' enables overwritting pod spec to add ephemeral PVC
          #     https://docs.gitlab.com/runner/executors/kubernetes/#overwrite-generated-pod-specifications
          environment = [
            "FF_USE_ADVANCED_POD_SPEC_CONFIGURATION=true",
            "FF_SCRIPT_SECTIONS=true",
            "CLOUD_CITY_TENANT=${var.tenant_name}",
            "CLOUD_CITY_CONTAINER_REGISTRY_ROOT=${var.runner_image_registry_root}",
            "CLOUD_CITY_CONTAINER_REGISTRY=${var.runner_image_registry_root}/${var.tenant_name}",
            "CLOUD_CITY_PLATFORM_AWS_ACCOUNT_ID=${data.aws_caller_identity.current.account_id}",
            "TMPDIR=${local.tmp_dir}",
          ]
          # Many containers need tmp to have specific permissions, including the sticky bit set. Since different runner
          # jobs can potentially have different users (depending on the image and the securityContext.fsGroup), there's
          # not a Kubernetes-native way to force the volume mount to have the right perms without potentially breaking
          # or contradicting some containers' behavior and expectation. Instead, we do a non-recursive chmod on /tmp
          # in order to fix the issue. An example of a container that requires this behavior is
          # 'docker/library/python:3.12.10-slim'. To observe the failure, run `apt-get update` in a build against that
          # container with and without the below line.
          pre_build_script = "chmod 1777 '${local.tmp_dir}' || echo 'Could not update tmpfs permissions'"
          [runners.kubernetes]
            # cpu and memory to maximize stability
            cpu_request = "${var.builder_cpu}"
            cpu_request_overwrite_max_allowed = "10"
            memory_request = "${var.builder_memory}"
            memory_limit = "${var.builder_memory}"
            memory_request_overwrite_max_allowed = "1Ti"
            memory_limit_overwrite_max_allowed = "1Ti"
            helper_image = "${var.runner_image_registry_root}/platform/docker/gitlab/gitlab-runner-helper:x86_64-v{{.Chart.AppVersion}}"
            helper_cpu_request_overwrite_max_allowed = "10"
            helper_memory_request_overwrite_max_allowed = "1Ti"
            helper_memory_limit_overwrite_max_allowed = "1Ti"
            service_cpu_request = "${var.service_cpu}"
            service_cpu_request_overwrite_max_allowed = "10"
            service_memory_request = "${var.service_memory}"
            service_memory_limit = "${var.service_memory}"
            service_memory_request_overwrite_max_allowed = "1Ti"
            service_memory_limit_overwrite_max_allowed = "1Ti"
            namespace = "{{.Release.Namespace}}"
            privileged = ${var.runner_is_privilaged}
            # Default image used by runner jobs
            # TODO change this once we have a canonical default runner image
            image = "${var.runner_image_registry_root}/${var.tenant_name}/docker/library/alpine"
            # Credentials used by jobs (not just runner pods)
            service_account = "${module.runner_iam_role.service_account_name}"
            [[runners.kubernetes.volumes.secret]]
              # GitLab cert mounted so it can be installed on runner as part of a job
                # before_script:
                #   - cp /etc/gitlab-runner/certs/gitlab.cloud-city.crt /usr/local/share/ca-certificates/
                #   - update-ca-certificates
              name = "${kubernetes_secret.gitlab_certificate.metadata[0].name}"
              mount_path = "${var.gitlab_certificate_path}"
            [[runners.kubernetes.pod_spec]]
              # Since build code can write anywhere in the build container and use up shared ephemeral storage on the
              # runner nodes, we can restrict writes to only go to the ephemeral, cleaned-up-after-each-job volumes we
              # provision below by mounting the container's filesystem as read-only. Doing this gives users whose code
              # writes to shared storage a form of "early warning" that they need to fix their builds to write under
              # the /builds mountpoint so as not to eventually cause problems for other tenants due to full disks.
              # We don't use the chart-level podSecurityContext variable because it doesn't support the
              # readOnlyRootFilesystem yet; that may change in a future enhancement by GitLab.
              name = "build-root-read-only"
              patch = '''
                  containers:
                  - name: build
                    securityContext:
                      readOnlyRootFilesystem: ${var.read_only_root}
                '''
              patch_type = "strategic"
            [[runners.kubernetes.pod_spec]]
              # Using PVC instead of [ephemeral storage config](https://docs.gitlab.com/runner/executors/kubernetes/#create-a-pvc-for-each-build-job-by-modifying-the-pod-spec)
              # because that storage relies on the node volume - this is separate; therefore, more stable
              name = "ephemeral-build-pvc"
              patch = '''
                containers:
                - name: build
                  volumeMounts:
                  - name: builds
                    mountPath: "${local.builds_dir}"
                    subPath: "${trim(local.builds_dir, "/")}"
                  - name: builds
                    mountPath: "${local.tmp_dir}"
                    subPath: "${trim(local.tmp_dir, "/")}"
                - name: helper
                  volumeMounts:
                  - name: builds
                    mountPath: "${local.builds_dir}"
                    subPath: "${trim(local.builds_dir, "/")}"
                volumes:
                - name: builds
                  ephemeral:
                    volumeClaimTemplate:
                      spec:
                        storageClassName: "${kubernetes_storage_class.runner_ebs_sc.metadata[0].name}"
                        accessModes: [ ReadWriteOnce ]
                        resources:
                          requests:
                            storage: "${var.scratch_space_size_gb}Gi"
              '''
          # Ref: https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscaches3-section
          [runners.cache]
            Type = "s3"
            Path = "runners"
            Shared = true
            [runners.cache.s3]
              ServerAddress = "s3.amazonaws.com"
              AuthenticationType = "iam"
              # Runners should use the IRSA role by default, but that has been found not to work, so we set it
              # explicitly. Since the IRSA role can assume itself, this works well. Using RoleARN also enables some
              # improved performance and additional S3 utilization efficiencies by the runners.
              RoleARN = "${module.runner_iam_role.iam_role_arn}"
              BucketLocation= "us-east-1"
              BucketName = "${module.runner_cache_s3_bucket.bucket_id}"
    YAML
  ]
}
