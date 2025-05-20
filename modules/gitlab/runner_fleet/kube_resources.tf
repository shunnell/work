resource "kubernetes_namespace" "fleet_namespace" {
  metadata {
    name = local.runner_fleet_name
  }
}

resource "kubernetes_secret" "gitlab_certificate" {
  metadata {
    name      = local.secret_name
    namespace = kubernetes_namespace.fleet_namespace.metadata[0].name
  }
  data = {
    "${var.gitlab_mothership_domain}.crt" = var.gitlab_certificate
  }
}
