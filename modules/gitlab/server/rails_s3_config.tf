resource "kubernetes_secret" "rails_s3_config" {
  metadata {
    name      = var.rails_s3_secret_name
    namespace = kubernetes_namespace.gitlab_namespace.metadata[0].name
  }
  type = "Opaque"
  data = {
    connection = "provider: AWS\nregion: us-east-1\nuse_iam_profile: true\n"
  }
  depends_on = [kubernetes_namespace.gitlab_namespace]
}