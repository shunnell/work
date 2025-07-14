resource "kubernetes_manifest" "argocd_app_project" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = var.project_name
      namespace = var.argocd_namespace
    }
    spec = var.project_configuration
  }
}
