output "gateway_class_name" {
  description = "Name of the GatewayClass"
  value       = local.deploy_lb ? local.gateway_class_name : null
}

output "ingress_class_name" {
  description = "Name of the IngressClass"
  value       = local.deploy_lb ? local.ingress_class_name : null
}

output "web_port" {
  description = "Port for inbound HTTP traffic"
  value       = local.deploy_lb ? local.web_port : null
}

output "websecure_port" {
  description = "Port for inbound HTTPS traffic"
  value       = local.deploy_lb ? local.websecure_port : null
}

output "cluster_issuer" {
  description = "Cluster certificate issuer name"
  value       = local.cluster_issuer
}
