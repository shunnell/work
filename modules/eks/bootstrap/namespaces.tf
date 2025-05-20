# Dynamically create namespaces
resource "kubernetes_namespace" "namespaces" {
  for_each                         = local.default_namespaces
  wait_for_default_service_account = true
  metadata {
    name = each.value
  }
}
