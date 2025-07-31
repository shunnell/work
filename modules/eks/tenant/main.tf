resource "kubernetes_namespace" "this" {
  metadata {
    name   = var.tenant_name
    labels = var.tags
  }
  wait_for_default_service_account = true
}

resource "kubernetes_manifest" "this" {
  manifest = yamldecode(<<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: Gateway
    metadata:
      name: ${var.tenant_name}-gateway
      namespace: ${kubernetes_namespace.this.metadata[0].name}
      annotations:
        cert-manager.io/cluster-issuer: ${var.cluster_issuer}
    spec:
      gatewayClassName: ${var.gateway_class_name}
      listeners:
      %{for name, domain in var.tenant_domain_names}
        - protocol: HTTPS
          port: ${var.websecure_port}
          hostname: "*.${domain}"
          name: https-wild-${name}
          tls:
            mode: Terminate
            certificateRefs:
              - name: tls-${name}
          allowedRoutes:
            namespaces:
              from: Same
        - protocol: HTTPS
          port: ${var.websecure_port}
          hostname: ${domain}
          name: https-${name}
          tls:
            mode: Terminate
            certificateRefs:
              - name: tls-${name}
          allowedRoutes:
            namespaces:
              from: Same
        - protocol: HTTP
          port: ${var.web_port}
          hostname: "*.${domain}"
          name: http-wild-${name}
          allowedRoutes:
            namespaces:
              from: Same
        - protocol: HTTP
          port: ${var.web_port}
          hostname: ${domain}
          name: http-${name}
          allowedRoutes:
            namespaces:
              from: Same
      %{endfor}
    YAML
  )
}
