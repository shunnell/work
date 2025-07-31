resource "kubernetes_namespace" "nexus_namespace" {
  metadata {
    name = local.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }
}
