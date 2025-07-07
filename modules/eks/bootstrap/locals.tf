data "aws_region" "current" {}

locals {
  image_path_root            = "${var.chart_ecr_image_account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com/platform"
  prefered_argocd_dns        = "argocd.${var.cluster_name}.${var.account_name}.cloud-city"
  external_secrets_repo_root = "${local.image_path_root}/github/external-secrets"
}
