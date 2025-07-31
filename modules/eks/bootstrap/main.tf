data "aws_region" "current" {}

locals {
  region          = data.aws_region.current.region
  ecr_domain      = "${var.chart_ecr_image_account_id}.dkr.ecr.${local.region}.amazonaws.com"
  image_path_root = "${local.ecr_domain}/platform"

  external_secrets_repo_root = "${local.image_path_root}/github/external-secrets"

  argocd_domain_name          = "argocd.${var.root_domain_name}"
  argocd_service_account_name = "argocd-repo-server"
}

# Dynamically create namespaces
resource "kubernetes_namespace" "namespaces" {
  for_each = toset(compact([
    var.enable_argocd ? "argocd" : null,
    "external-secrets"
  ]))

  metadata {
    name   = each.value
    labels = var.tags
  }

  wait_for_default_service_account = true
}

resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = true
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  parameters = {
    encrypted = "true"
    type      = "gp3"
  }
}

module "alarms" {
  source       = "./eks-automated-monitoring"
  cluster_name = var.cluster_name
  tags         = var.tags
}
