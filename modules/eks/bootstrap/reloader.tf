resource "kubernetes_namespace" "reloader" {
  count = var.enable_argocd ? 1 : 0
  metadata {
    name = "reloader"
  }
  wait_for_default_service_account = true
}

module "reloader_argocd_app" {
  count                   = var.enable_argocd ? 1 : 0
  source                  = "../../argocd/application"
  argocd_namespace        = kubernetes_namespace.namespaces["argocd"].metadata[0].name
  aws_ecr_service_account = local.argocd_service_account_name

  app_namespace          = kubernetes_namespace.reloader[0].metadata[0].name
  app_helm_chart         = "reloader"
  app_helm_chart_repo    = "${local.internal_helm_path_root}/stakater"
  app_helm_chart_version = "2.1.4"
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

  depends_on = [module.external_secrets.status, module.argocd[0].status]
}
