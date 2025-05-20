module "gitlab_runner" {
  source = "../../helm"

  release_name  = local.runner_fleet_name
  repository    = "${var.runner_image_registry_root}/helm/gitlab" #"https://charts.gitlab.io"
  chart         = "gitlab-runner"
  namespace     = kubernetes_namespace.fleet_namespace.metadata[0].name
  chart_version = "0.76.0"
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
      registry: ${var.runner_image_registry_root}/ecr-public
      image: gitlab/gitlab-runner
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
          builds_dir = "${var.builds_dir}"
          # 'FF_USE_ADVANCED_POD_SPEC_CONFIGURATION' enables overwritting pod spec to add ephemeral PVC
          #     https://docs.gitlab.com/runner/executors/kubernetes/#overwrite-generated-pod-specifications
          environment = ["FF_USE_ADVANCED_POD_SPEC_CONFIGURATION=true"]
          [runners.kubernetes]
            # cpu and memory to maximize stability
            cpu_request = "${var.builder_cpu}"
            cpu_request_overwrite_max_allowed = "10"
            memory_request = "${var.builder_memory}"
            memory_limit = "${var.builder_memory}"
            memory_request_overwrite_max_allowed = "1Ti"
            memory_limit_overwrite_max_allowed = "1Ti"
            helper_image = "${var.runner_image_registry_root}/ecr-public/gitlab/gitlab-runner-helper:x86_64-v{{.Chart.AppVersion}}"
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
            image = "${var.runner_image_registry_root}/ecr-public/docker/library/alpine"
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
              # Using PVC instead of [ephemeral storage config](https://docs.gitlab.com/runner/executors/kubernetes/#create-a-pvc-for-each-build-job-by-modifying-the-pod-spec)
              # because that storage relies on the node volume - this is separate; therefore, more stable
              name = "ephemeral-build-pvc"
              patch = '''
                containers:
                - name: build
                  volumeMounts:
                  - name: builds
                    mountPath: ${var.builds_dir}
                - name: helper
                  volumeMounts:
                  - name: builds
                    mountPath: ${var.builds_dir}
                volumes:
                - name: builds
                  ephemeral:
                    volumeClaimTemplate:
                      spec:
                        accessModes: [ ReadWriteOnce ]
                        resources:
                          requests:
                            storage: ${var.builder_volume}
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
