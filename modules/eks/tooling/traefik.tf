module "traefik_crds" {
  count = local.deploy_lb ? 1 : 0

  source = "../../argocd/application"

  argocd_namespace        = var.argocd_namespace
  aws_ecr_service_account = var.aws_ecr_service_account

  app_helm_chart         = "traefik-crds"
  app_helm_chart_repo    = "${local.internal_helm_path_root}/traefik"
  app_helm_chart_version = var.traefik_crds_helm_chart_version
  self_heal              = true
  app_sync_wave          = -1 # CRDs should be deployed before everything else
  app_helm_values        = <<-YAML
    gatewayAPI: true
    hub: true
    YAML
}

module "traefik" {
  count = local.deploy_lb ? 1 : 0

  source = "../../argocd/application"

  argocd_namespace        = var.argocd_namespace
  aws_ecr_service_account = var.aws_ecr_service_account

  app_namespace          = local.traefik_namespace
  app_helm_chart         = "traefik"
  app_helm_chart_repo    = "${local.internal_helm_path_root}/traefik"
  app_helm_chart_version = var.traefik_helm_chart_version
  create_namespace       = true
  self_heal              = true
  app_helm_values        = <<-YAML
    api:
      dashboard: true
      debug: true
    image:
      registry: ${local.image_path_root}/docker
      repository: library/traefik
    deployment:
      replicas: ${var.api_gateway_replicas}
    ingressClass:
      name: ${local.ingress_class_name}
    gatewayClass:
      name: ${local.gateway_class_name}
    providers:
      kubernetesGateway:
        enabled: true
    gateway:
      enabled: false # so no one tries to use the traefik gateway - should manage separately
    ingressRoute:
      healthcheck:
        enabled: true
        # check the Traefik Poxy Helm chart values for what these "entry points" are - adding "web" and "websecure"
        entryPoints:
          - "traefik"
          - "web"
          - "websecure"
    logs:
      general:
        format: json
      access:
        enabled: true
        format: json
        addInternals: true
        fields:
          headers:
            defaultmode: keep
            names:
              Authorization: redact
      addInternals: true
    metrics:
      addInternals: true
      prometheus:
        addRouterLabels: true
      otlp:
        addRouterLabels: true
    tracing:
      addInternals: true
    global:
      checkNewVersion: false
    ports:
      web:
        port: ${local.web_port}
      websecure:
        port: ${local.websecure_port}
    service:
      loadBalancerSourceRanges: ["${join("\", \"", var.allowed_cidr_blocks)}"]
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-name: ${local.lb_name}
        service.beta.kubernetes.io/aws-load-balancer-type: external
        service.beta.kubernetes.io/aws-load-balancer-scheme: internal
        service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
        service.beta.kubernetes.io/aws-load-balancer-attributes: deletion_protection.enabled=true,load_balancing.cross_zone.enabled=true
    resources:
      requests:
        cpu: 200m
        memory: 250Mi
      limits:
        memory: 400Mi
    # don't add anymore to this unless absolutely necessary (the 'other' chart doesn't have an 'extaObjects' type of value)
    extraObjects:
      # Traefik Dashboard
      - kind: Secret
        apiVersion: v1
        metadata:
          name: traefik-dashboard-auth
          namespace: ${local.traefik_namespace}
        data:
          # since the dashboard and api is read-only, it should be fine to leave this here
          password: YWRtaW4=
          username: YWRtaW4=
        type: kubernetes.io/basic-auth
      - apiVersion: traefik.io/v1alpha1
        kind: Middleware
        metadata:
          name: auth-traefik-dashboard
          namespace: ${local.traefik_namespace}
        spec:
          basicAuth:
            secret: traefik-dashboard-auth
      - apiVersion: traefik.io/v1alpha1
        kind: IngressRoute
        metadata:
          name: dashboard
          namespace: ${local.traefik_namespace}
        spec:
          routes:
            - match: Host(`traefik.${var.root_domain_name}`)
              kind: Rule
              services:
                - name: api@internal
                  kind: TraefikService
              middlewares:
                - name: auth-traefik-dashboard
      # AWS Cluster Issuer
      - apiVersion: awspca.cert-manager.io/v1beta1
        kind: AWSPCAClusterIssuer
        metadata:
          name: ${local.cluster_issuer}
        spec:
          arn: ${var.root_ca_arn}
          region: ${local.region}
      # ArgoCD
      - apiVersion: gateway.networking.k8s.io/v1
        kind: Gateway
        metadata:
          name: argocd-gw
          namespace: ${var.argocd_namespace}
          annotations:
            cert-manager.io/cluster-issuer: ${local.cluster_issuer}
        spec:
          gatewayClassName: ${local.gateway_class_name}
          listeners:
            - protocol: HTTPS
              hostname: "*.${var.argocd_domain_name}"
              port: ${local.websecure_port}
              name: argocd-https-wild
              tls:
                mode: Terminate
                certificateRefs:
                  - name: argocd-tls
                    group: ''
                    kind: Secret
              allowedRoutes:
                namespaces:
                  from: Same
            - protocol: HTTPS
              hostname: ${var.argocd_domain_name}
              port: ${local.websecure_port}
              name: argocd-https
              tls:
                mode: Terminate
                certificateRefs:
                  - name: argocd-tls
                    group: ''
                    kind: Secret
              allowedRoutes:
                namespaces:
                  from: Same
            - protocol: HTTP
              hostname: "*.${var.argocd_domain_name}"
              port: ${local.web_port}
              name: argocd-http-wild
              allowedRoutes:
                namespaces:
                  from: Same
            - protocol: HTTP
              hostname: ${var.argocd_domain_name}
              port: ${local.web_port}
              name: argocd-http
              allowedRoutes:
                namespaces:
                  from: Same
      - apiVersion: gateway.networking.k8s.io/v1
        kind: HTTPRoute
        metadata:
          name: argocd-http
          namespace: ${var.argocd_namespace}
        spec:
          parentRefs:
            - name: argocd-gw
              group: gateway.networking.k8s.io
              kind: Gateway
          rules:
            - backendRefs:
                - name: argocd-server
                  port: 80
                  kind: Service
                  group: ''
                  weight: 1
              matches:
                - path:
                    type: PathPrefix
                    value: /
      - apiVersion: gateway.networking.k8s.io/v1
        kind: GRPCRoute
        metadata:
          name: argocd-grpc
          namespace: ${var.argocd_namespace}
        spec:
          parentRefs:
            - name: argocd-gw
              group: gateway.networking.k8s.io
              kind: Gateway
          rules:
            - matches:
                - headers:
                    - name: Content-Type
                      type: Exact
                      value: application/grpc
              backendRefs:
                - name: argocd-server
                  port: 80
                  kind: Service
                  group: ''
                  weight: 1
    YAML

  depends_on = [module.traefik_crds]
}

## TODO
# kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/traefik -n traefik
# kubectl get service/traefik -n traefik -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
