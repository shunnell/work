# Dynamically create namespaces
resource "kubernetes_namespace" "namespaces" {
  for_each                         = toset(compact([var.enable_argocd ? "argocd" : null, "external-secrets", "external-dns"]))
  wait_for_default_service_account = true
  metadata {
    name = each.value
  }
}
