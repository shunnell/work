module "reloader_argocd_app" {
  source = "../../argocd/application"

  argocd_namespace        = var.argocd_namespace
  aws_ecr_service_account = var.aws_ecr_service_account

  app_namespace          = "reloader"
  create_namespace       = true
  app_helm_chart         = "reloader"
  app_helm_chart_repo    = "${local.internal_helm_path_root}/stakater"
  app_helm_chart_version = var.reloader_helm_chart_version
  self_heal              = true
  app_helm_values        = <<-YAML
    image:
      repository: ${local.image_path_root}/github/stakater/reloader
    reloader:
      # autoReloadAll: false # the default is to only reload things that have the appropriate annotations
      isArgoRollouts: true
      reloadOnCreate: true
      reloadOnDelete: true
      syncAfterRestart: true
      reloadStrategy: annotations
      logFormat: json
      readOnlyRootFileSystem: true
      enableMetricsByNamespace: true
      resources:
        limits:
          memory: "512Mi"
        requests:
          cpu: "10m"
          memory: "128Mi"
      livenessProbe:
        timeoutSeconds: 5
        failureThreshold: 5
        periodSeconds: 10
        successThreshold: 1
      readinessProbe:
        timeoutSeconds: 15
        failureThreshold: 5
        periodSeconds: 10
        successThreshold: 1
    YAML
}
