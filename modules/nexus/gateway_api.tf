## To enable the gateway api, when the cert-manager is installed, the following resources need to be created:

resource "kubernetes_manifest" "gateway" {
  manifest = yamldecode(<<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: Gateway
    metadata:
      name: nexus-gw
      namespace: ${kubernetes_namespace.nexus_namespace.metadata[0].name}
      annotations:
        cert-manager.io/cluster-issuer: ${var.cluster_issuer}
    spec:
      gatewayClassName: ${var.gateway_class_name}
      listeners:
        - protocol: HTTPS
          hostname: "*.${var.nexus_domain_name}"
          port: 8443
          name: nexus-https-wild
          tls:
            mode: Terminate
            certificateRefs:
              - name: nexus-tls
          allowedRoutes:
            namespaces:
              from: Same
        - protocol: HTTPS
          hostname: ${var.nexus_domain_name}
          port: 8443
          name: nexus-https
          tls:
            mode: Terminate
            certificateRefs:
              - name: nexus-tls
          allowedRoutes:
            namespaces:
              from: Same
        - protocol: HTTP
          hostname: "*.${var.nexus_domain_name}"
          port: 8000
          name: nexus-http-wild
          allowedRoutes:
            namespaces:
              from: Same
        - protocol: HTTP
          hostname: ${var.nexus_domain_name}
          port: 8000
          name: nexus-http
          allowedRoutes:
            namespaces:
              from: Same
    YAML
  )
}

resource "kubernetes_manifest" "http_route" {
  manifest = yamldecode(<<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: nexus-http
      namespace: ${kubernetes_namespace.nexus_namespace.metadata[0].name}
    spec:
      parentRefs:
        - name: nexus-gw
      rules:
        - backendRefs:
          - name: nxrm-ha
            port: 8081
    YAML
  )
}