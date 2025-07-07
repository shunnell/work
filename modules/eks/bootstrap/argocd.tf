module "argocd" {
  count        = var.enable_argocd ? 1 : 0
  source       = "../../helm"
  repository   = "${local.image_path_root}/github/argoproj/argo-helm"
  chart        = "argo-cd"
  namespace    = kubernetes_namespace.namespaces["argocd"].metadata[0].name
  release_name = "argocd"
  # NB: the weird combination of repos (GHCR/github for the chart, quay for the argo image, ECR-public for dex, and
  # docker hub for redis) are intentional. Argo developers do not have a consistent publication practice
  # for their various components, and as such these values represent the places that can be counted upon to have the
  # appropriate, matching, latest versions of everything.
  chart_version = "8.1.0"
  atomic        = true
  force_update  = true
  # The CRDs/application manifests stick around even if ArgoCD itself is removed, so recreate_pods is safe.
  # NB: if this is found to cause problems due to replacement Argo installs having issues "adopting" pre-existing
  # argo CRD resources, it can be changed, but it smooths out destroy/replace/recreate in the mean time:
  recreate_pods = true
  timeout       = 1200            # Provisioning AWS NLBs takes ages.
  depends_on    = [module.awslbc] # Argo needs a load balancer

  values = [<<-YAML
    global:
      image:
        repository: "${local.image_path_root}/quay/argoproj/argocd"
      domain: ${local.prefered_argocd_dns}
      logging:
        format: json
      addPrometheusAnnotations: true
    configs:
      cm:
        kustomize.buildOptions: --enable-helm --load-restrictor LoadRestrictionsNone
      params:
        server.insecure: true
    server:
      service:
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: external
          service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
          service.beta.kubernetes.io/aws-load-balancer-attributes: load_balancing.cross_zone.enabled=true
          service.beta.kubernetes.io/aws-load-balancer-name: argocd-${var.cluster_name}
          service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: prefered_domain=${local.prefered_argocd_dns}
        type: LoadBalancer
        loadBalancerClass: service.k8s.aws/nlb
    dex:
      image:
        repository: ${local.image_path_root}/github/dexidp/dex
    redis:
      image:
        repository: ${local.image_path_root}/docker/library/redis
    YAML
  ]
}
