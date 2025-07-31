data "aws_lb" "gitlab_lb" {
  tags = {
    "elbv2.k8s.aws/cluster"    = var.cluster_name
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "ingress.k8s.aws/stack"    = var.release_name
  }

  depends_on = [module.gitlab]
}

# TODO update this appropriately to accomodate Ingress resources in addition to LoadBalancer resources.
output "gitlab_webserver_lb" {
  description = "AWS load balancer URL for GitLab"
  value       = data.aws_lb.gitlab_lb
}

output "gitlab_namespace" {
  value = kubernetes_namespace.gitlab_namespace.metadata[0].name
}

output "priority_class" {
  value = kubernetes_priority_class.this.id
}

output "rds_secret_name" {
  value = kubernetes_manifest.rds_secret.manifest["spec"]["target"]["name"]
}
