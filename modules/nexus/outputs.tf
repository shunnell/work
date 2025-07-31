output "nexus_namespace" {
  value = kubernetes_namespace.nexus_namespace.metadata[0].name
}

output "nexus_deployment" {
  value       = module.nexus.metadata
  description = "The state of the helm deployment"
}
