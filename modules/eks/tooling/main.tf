data "aws_region" "current" {}

locals {
  region                  = data.aws_region.current.region
  ecr_domain              = "${var.chart_ecr_image_account_id}.dkr.ecr.${local.region}.amazonaws.com"
  image_path_root         = "${local.ecr_domain}/platform"
  internal_helm_path_root = "${local.image_path_root}/internal/helm"

  cert_manager_namespace = "cert-manager"
  cert_manager_registry  = "${local.image_path_root}/quay/jetstack"
  cluster_issuer         = "bespin-root-ca"

  deploy_lb          = var.vpc_id != null && var.nodegroup_security_group_id != null
  gateway_class_name = "traefik"
  ingress_class_name = "traefik"
  traefik_namespace  = "traefik"
  lb_name            = "${var.cluster_name}-traefik"
  # defaults - for export and use by other tools that have an exposed web UI
  web_port       = 8000
  websecure_port = 8443
}
