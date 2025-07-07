resource "kubernetes_secret" "okta_saml_auth" {
  metadata {
    name      = "okta-saml-auth"
    namespace = kubernetes_namespace.gitlab_namespace.metadata[0].name
  }
  data = {
    okta_prod = <<-YAML
      name: saml
      label: OKTA
      groups_attribute: groups
      args:
        assertion_consumer_service_url: "https://${var.domain}/users/auth/saml/callback"
        idp_cert_fingerprint: "${local.idp_cert_fingerprint}"
        idp_sso_target_url: https://state.okta.com/app/state_cagitlabcloudcity_1/${local.oauth_token}/sso/saml
        issuer: "http://${var.domain}"
        name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
      YAML
  }
}

resource "kubernetes_secret" "rails_secret" {
  metadata {
    name      = "rails-secret"
    namespace = kubernetes_namespace.gitlab_namespace.metadata[0].name
  }
  data = {
    "secrets.yml" = <<-YAML
      ${yamlencode(local.rails_secret)}
      YAML
  }
}

module "gitlab" {
  source = "../../helm"

  release_name  = var.release_name
  repository    = "https://charts.gitlab.io"
  chart         = "gitlab"
  namespace     = kubernetes_namespace.gitlab_namespace.metadata[0].name
  chart_version = var.chart_version
  timeout       = 1200 # Provisioning AWS NLBs takes ages.
  # remove block after upgrade to chart version 9.x
  set = {
    # set to 'false' on upgrade to 9.x
    "prometheus.install"  = true
    "certmanager.install" = false
  }
  # ref material: https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/values.yaml?ref_type=heads
  values = [<<-YAML
    installCertmanager: false
    certmanager-issuer:
      email: CA-CST-Cloud-City-Platform@state.gov
    global:
      railsSecrets:
        secret: ${kubernetes_secret.rails_secret.metadata[0].name}
      hosts:
        domain: ${var.domain}
        https: true
        gitlab:
          name: ${var.domain}
      kubectl:
        image:
          repository: "${local.custom_image_repo}/kubectl"
      certificates:
        image:
          repository: "${local.custom_image_repo}/certificates"
      gitlabBase:
        image:
          repository: "${local.custom_image_repo}/gitlab-base"
      ingress:
        # Common annotations used by kas, registry, and webservice
        annotations:
          alb.ingress.kubernetes.io/group.name: ${var.release_name}
          alb.ingress.kubernetes.io/backend-protocol: HTTP
          alb.ingress.kubernetes.io/healthcheck-path: /-/readiness
          alb.ingress.kubernetes.io/healthcheck-port: traffic-port
          alb.ingress.kubernetes.io/certificate-arn: ${var.acm_cert_arn}
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
        object_store:
          bucket: ${var.pages_bucket}
      appConfig:
        omniauth:
          enabled: true
          syncProfileFromProvider: []
          syncProfileAttributes: ["email"]
          allowSingleSignOn: ["saml"]
          blockAutoCreatedUsers: false
          autoLinkLdapUser: false
          autoLinkSamlUser: true
          autoLinkUser: []
          externalProviders: []
          allowBypassTwoFactor: []
          providers:
            - secret: ${kubernetes_secret.okta_saml_auth.metadata[0].name}
              key: okta_prod
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
          bucket: ${var.lfs_bucket}
        packages:
          bucket: ${var.pkg_bucket}
        terraformState:
          bucket: ${var.tf_state_bucket}
          enabled: true
        uploads:
          bucket: ${var.uploads_bucket}
        backups:
          bucket: ${var.backup_bucket}
          tmpBucket: ${var.tmp_backup_bucket}
          objectStorage:
            backend: s3
        object_store:
          enabled: true
          proxy_download: true
          connection:
            secret: ${kubernetes_secret.rails_s3_config.metadata[0].name}
            key: connection
      registry:
        enabled: false
        bucket: ${var.registry_bucket}
      serviceAccount:
        enabled: true
        create: true
        annotations:
          eks.amazonaws.com/role-arn: ${var.irsa_role}
    gitlab:
      gitaly:
        annotations:
          cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
        antiAffinity: soft
        gracefulRestartTimeout: 1
        image:
          repository: "${local.custom_image_repo}/gitaly"
        persistence:
          size: 250Gi
          storageClass: ${kubernetes_storage_class.gitaly_retain.metadata[0].name}
        maxUnavailable: 0 
        priorityClassName: ${kubernetes_priority_class.this.metadata[0].name}
        cgroups:
          enabled: true
          initContainer:
            image:
              repository: "${local.custom_image_repo}/gitaly-init-cgroups"
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
            cpu: 4
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
          repository: "${local.custom_image_repo}/gitlab-exporter"
      gitlab-shell:
        enabled: false
        service:
          type: LoadBalancer
        image:
          repository: "${local.custom_image_repo}/gitlab-shell"
      gitlab-pages:
        image:
          repository: "${local.custom_image_repo}/gitlab-pages"
      kas:
        ingress:
          # Specific annotations needed for kas service to support websockets
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
          repository: "${local.custom_image_repo}/gitlab-kas"
      migrations:
        enabled: true
        image:
          repository: "${local.custom_image_repo}/gitlab-toolbox-ee"
      sidekiq:
        maxReplicas: 3
        maxUnavailable: 1
        minReplicas: 2
        resources:
          limits:
            memory: 4Gi
          requests:
            cpu: 900m # Assume single-process, 1 CPU
            memory: 2Gi
        hpa:
          cpu:
            targetAverageValue: 700m
        image:
          repository: "${local.custom_image_repo}/gitlab-sidekiq-ee"
      toolbox:
        persistence:
          enabled: true
          size: ${var.toolbox_storage}
        image:
          repository: "${local.custom_image_repo}/gitlab-toolbox-ee"
        backups:
          objectStorage:
            config:
              secret: ${kubernetes_secret.s3cmd_config.metadata[0].name} 
              key: config
          cron:
            enabled: true
            schedule: ${var.backup_cron_schedule}
            extraArgs: ${var.backup_cron_extra_args}
            persistance:
              enabled: true
              useGenericEphemeralVolume: true
              size: ${var.toolbox_storage}
      webservice:
        maxReplicas: 3
        maxUnavailable: 1
        minReplicas: 2
        resources:
          limits:
            memory: 7Gi # roughly, 1.75GB/worker
          requests:
            cpu: 4 # requests.cpu <= workerProcesses
            memory: 5Gi # roughly, 1.25GB/worker
        workerProcesses: 4
        hpa:
          cpu:
            targetAverageValue: 1600m
        ingress:
          proxyBodySize: 0 # To allow large file uploads like imports
        image:
          repository: "${local.custom_image_repo}/gitlab-webservice-ee"
        workhorse:
          image: "${local.custom_image_repo}/gitlab-workhorse-ee"
    gitlab-runner:
      install: false
    nginx-ingress:
      enabled: false
    postgresql:
      install: false
    shared-secrets:
      selfsign:
        image:
          repository: "${local.custom_image_repo}/cfssl-self-sign"
    redis:
      install: false
    registry:
      enabled: false
    YAML
  ]
}
