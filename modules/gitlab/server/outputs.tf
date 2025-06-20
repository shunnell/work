output "gitlab_namespace" {
  value = kubernetes_namespace.gitlab_namespace.metadata[0].name
}

output "priority_class" {
  value = kubernetes_priority_class.this.id
}

output "rds_secret_name" {
  value = kubernetes_manifest.rds_secret.manifest["spec"]["target"]["name"]
}