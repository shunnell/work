locals {
  # Load common variables
  common_vars  = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
  network_vars = read_terragrunt_config("${get_path_to_repo_root()}/network/account.hcl")
  infra_vars   = read_terragrunt_config("${get_path_to_repo_root()}/infra/platform/vpn/vpn_vars.hcl")

  # Extract commonly used variables
  common_identifier             = local.common_vars.locals.common_identifier
  vpc_name                      = "${local.common_identifier}-vpc27-us-east-1"
  network_terragrunter_role_arn = local.network_vars.locals.terragrunter_role_arn
  network_region                = local.network_vars.locals.region

  # Transit Gateway Non-Prod
  transit_gateway_id = local.infra_vars.locals.transit_gateway_id

  # Transit Gateway Attachment (Non-Prod)
  vpn_transit_gateway_attachment_id = local.infra_vars.locals.vpn_transit_gateway_attachment_id
  dso_transit_gateway_attachment_id = local.infra_vars.locals.dso_transit_gateway_attachment_id

  # Transit Gateway Route Table
  vpn_transit_gateway_route_table_id = local.infra_vars.locals.vpn_transit_gateway_route_table_id
  dso_transit_gateway_route_table_id = local.infra_vars.locals.dso_transit_gateway_route_table_id

  # common CIDR blocks (VPN and DSO)
  dso_cidr_block = local.infra_vars.locals.dso_cidr_block
  vpn_cidr_block = local.infra_vars.locals.vpn_cidr_block

  # VPC CIDR block
  vpc_cidr_block = "172.27.0.0/20"
}