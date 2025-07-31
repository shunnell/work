output "argocd_namespace" {
  description = "Namespace of ArgoCD-server; can be used in other pipelines, such as the 'argocd-gw' Gateway configuration in '../tooling/traefik.tf"
  value       = var.enable_argocd ? kubernetes_namespace.namespaces["argocd"].metadata[0].name : null
}

output "argocd_domain_name" {
  description = "Domain for ArgoCD in this cluster; can be used in other pipelines, such as the 'argocd-gw' Gateway configuration in '../tooling/traefik.tf"
  value       = var.enable_argocd ? local.argocd_domain_name : null
}

output "argocd_service_account_name" {
  description = "Service account for use with ArgoCD applications"
  value       = var.enable_argocd ? local.argocd_service_account_name : null
}

output "root_domain_name" {
  description = "Root DNS passthrough - check variables for details"
  value       = var.root_domain_name
}

output "root_ca_arn" {
  description = "ARN of the root CA - used by a Custom Resource in Kubernetes"
  value       = var.root_ca_arn
}
