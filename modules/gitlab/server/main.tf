module "gitlab" {
  source = "../../helm"

  release_name  = var.release_name
  repository    = "${var.gitlab_image_registry_root}/internal/helm" # TODO use "https://charts.gitlab.io" when available
  chart         = "gitlab"
  namespace     = kubernetes_namespace.gitlab_namespace.metadata[0].name
  chart_version = var.chart_version
  # # The below invocation should be complete and declarative, so things can be fully replaced:
  force_update = true
  values = [
    <<-YAML
    certmanager:
      install: false
      # cert-manager deployment path: https://gitlab.cloud-city/cloud-city/platform/gitops/kubernetes/-/tree/main/_base/_infrastructure/cert-manager?ref_type=heads
    certmanager-issuer:
      email: CA-CST-Cloud-City-Platform@state.gov
    # --- Global settings ---
    global:
      hosts:
        domain: ${var.gitlab_domain}  
        https: true
      kubectl:
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/kubectl"                   
      certificates:
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/certificates"
      gitlabBase:
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-base"
      ingress:
        annotations:
          alb.ingress.kubernetes.io/backend-protocol: HTTP
          alb.ingress.kubernetes.io/healthcheck-path: /-/readiness
          alb.ingress.kubernetes.io/healthcheck-port: traffic-port
          alb.ingress.kubernetes.io/certificate-arn: ${var.acm_cert_arn}
          alb.ingress.kubernetes.io/group.name: gitlab
          alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
          alb.ingress.kubernetes.io/scheme: internal
          alb.ingress.kubernetes.io/target-type: ip
          kubernetes.io/ingress.class: alb
        class: alb
        configureCertmanager: false
        enabled: true
        provider: aws
        tls:
          enabled: false
      psql:
        host: ${var.rds_endpoint}
        password:
          key: password
          secret: ${kubernetes_manifest.rds_secret.manifest.spec.target.name}
      redis:
        auth:
          key: password
          secret: ${kubernetes_manifest.redis_secret.manifest.spec.target.name}
        host: ${var.redis_endpoint}
        scheme: rediss
      minio:
        enabled: false
      pages:
        enabled: true
      appConfig:
        artifacts:
          bucket: ${var.artifacts_bucket} 
        ciSecureFiles:
          bucket: ${var.ci_secure_bucket} 
          enabled: true
        dependencyProxy:
          bucket: ${var.dependency_proxy_bucket} 
          enabled: true
        externalDiffs:
          bucket: ${var.mr_diffs_bucket} 
          enabled: true
        lfs:
          bucket: ${var.gitlab_lfs_bucket}
        packages:
          bucket: ${var.gitlab_pkg_bucket}
        terraformState:
          bucket: ${var.tf_state_bucket}
          enabled: true
        uploads:
          bucket: ${var.gitlab_uploads_bucket}
        backups:
          bucket: ${var.gitlab_backup_bucket}
          tmpBucket: ${var.gitlab_tmp_backup_bucket}
          objectStorage:
            backend: s3
        object_store:
          enabled: true
          proxy_download: true
          connection:
            secret: ${kubernetes_secret.rails_s3_config.metadata[0].name}
            key: connection
         
      serviceAccount:
        enabled: true
        create: true
        annotations:
          eks.amazonaws.com/role-arn: ${var.irsa_role}
     # --- GitLab charts ---
    gitlab:      
      gitaly:
        annotations:
          cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
        antiAffinity: soft
        gracefulRestartTimeout: 1
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitaly"
        persistence:
          size: 250Gi
        maxUnavailable: 0 
        priorityClassName: ${kubernetes_priority_class.this.metadata[0].name}
        cgroups:
          enabled: true
          initContainer:
            image:
              repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitaly-init-cgroups"
      # Total limit across all repository cgroups
          memoryBytes: 15032385536 # 14GiB
          cpuShares: 1024
          cpuQuotaUs: 400000 # 4 cores
      # Per repository limits, 50 repository cgroups
          repositories:
            count: 50
            memoryBytes: 7516192768 # 7GiB
            cpuShares: 512
            cpuQuotaUs: 200000 # 2 cores
        resources:
          requests:
            cpu: 4000m
            memory: 15Gi
        securityContext:
          fsGroupChangePolicy: OnRootMismatch
        statefulset:
          readinessProbe:
            failureThreshold: 3
            initialDelaySeconds: 2
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 3
      gitlab-exporter:
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-exporter"
      gitlab-shell:
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-shell"
      gitlab-pages:
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-pages"
      kas:
        ingress:
          annotations:
            alb.ingress.kubernetes.io/healthcheck-path: /liveness
            alb.ingress.kubernetes.io/healthcheck-port: "8151"
            alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
            alb.ingress.kubernetes.io/load-balancer-attributes: idle_timeout.timeout_seconds=4000,routing.http2.enabled=false
            alb.ingress.kubernetes.io/target-group-attributes: stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=86400
            alb.ingress.kubernetes.io/target-type: ip
            kubernetes.io/tls-acme: "true"
            nginx.ingress.kubernetes.io/connection-proxy-header: "keep-alive"
            nginx.ingress.kubernetes.io/x-forwarded-prefix: "/path"                    
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-kas"
      migrations:
        enabled: true           
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-toolbox-ee"
      sidekiq:
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-sidekiq-ee"
      toolbox:
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-toolbox-ee"
        persistence:
          enabled: true
          size: 250Gi
        backups:
          objectStorage:
            config:
              secret: ${kubernetes_secret.s3cmd_config.metadata[0].name} 
              key: config            
      webservice:
        ingress:
          enabled: true
          path: /
          annotations:
            alb.ingress.kubernetes.io/group.name: gitlab
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-webservice-ee"
        workhorse:
          image: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/gitlab-workhorse-ee"
     #   --- Charts from requirements.yaml ---
    gitlab-runner:
      install: false
    nginx-ingress:
      enabled: false
    postgresql:
      install: false
    shared-secrets:
      enabled: true
      rbac:
        create: true
      selfsign:
        image:
          repository: "${var.gitlab_image_registry_root}/gitlab/gitlab-org/build/cng/cfssl-self-sign"     
    prometheus:
      install: true
    redis:
      install: false
    registry:
      enabled: false   
    YAML
  ]
}