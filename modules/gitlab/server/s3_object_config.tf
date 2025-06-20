resource "kubernetes_secret" "s3cmd_config" {
  metadata {
    name      = var.s3_secret_name
    namespace = kubernetes_namespace.gitlab_namespace.metadata[0].name
  }
  type = "Opaque"
  data = {
    config = "[default]\nbucket_location = us-east-1\n"
  }
  depends_on = [kubernetes_namespace.gitlab_namespace]
}