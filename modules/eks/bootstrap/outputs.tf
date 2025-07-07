data "kubernetes_service" "argocd_server" {
  count      = var.enable_argocd ? 1 : 0
  depends_on = [module.argocd]
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.namespaces["argocd"].metadata[0].name
  }
  lifecycle {
    postcondition {
      condition     = length(self.status) == 1 && length(self.spec) == 1
      error_message = "argocd-server Service did not report expected output"
    }
    postcondition {
      condition     = length(self.spec[0].port) > 0
      error_message = "argocd-server Service did not report being bound to load balancer ports"
    }
    # TODO update this appropriately to accomodate Ingress resources in addition to LoadBalancer resources.
    postcondition {
      condition     = self.spec[0].type == "LoadBalancer"
      error_message = "argocd-server Service did not report expected type"
    }
  }
}

# TODO update this appropriately to accomodate Ingress resources in addition to LoadBalancer resources.
output "argocd_server_endpoint" {
  description = "AWS load balancer URL for ArgoCD-server if 'enable_argocd' is true, otherwise null"
  value = var.enable_argocd ? {
    load_balancer_hostname = data.kubernetes_service.argocd_server[0].status[0].load_balancer[0].ingress[0].hostname
    cluster_ips            = data.kubernetes_service.argocd_server[0].spec[0].cluster_ips
    external_ips           = data.kubernetes_service.argocd_server[0].spec[0].external_ips
    ports = { for config in data.kubernetes_service.argocd_server[0].spec[0].port : config.name => {
      node_port          = tonumber(config.node_port)
      load_balancer_port = tonumber(config.port)
      pod_port           = tonumber(config.target_port)
    } }
  } : null
}