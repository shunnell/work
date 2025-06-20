locals {
  cluster_name = var.cluster_name
  region       = data.aws_region.current.region
  name         = "${local.region}-${local.cluster_name}"
  account_id   = data.aws_caller_identity.current.account_id
}
