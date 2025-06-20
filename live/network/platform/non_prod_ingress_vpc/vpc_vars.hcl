locals {
  # Load common variables
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  platform_vars = read_terragrunt_config(find_in_parent_folders("team.hcl"))
  vpn_vars      = read_terragrunt_config("${get_repo_root()}/infra/platform/vpn/vpn_vars.hcl").locals

  # Extract commonly used variables
  common_identifier = "${local.account_vars.locals.account}-${local.platform_vars.locals.team}-non-prod-ingress"
  vpc_name          = "${local.common_identifier}-vpc"

  # Transit Gateway
  transit_gateway_id = local.vpn_vars.transit_gateway_id

  # VPC CIDR block
  vpc_cidr_block = "172.20.48.0/20"
}