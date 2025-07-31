locals {
  # Load common variables
  network_vars = read_terragrunt_config("${get_path_to_repo_root()}/network/account.hcl").locals
  vpn_vars     = read_terragrunt_config("${get_path_to_repo_root()}/infra/platform/vpn/vpn_vars.hcl").locals
  infra_vars   = read_terragrunt_config("${get_repo_root()}/infra/account.hcl")

  # Extract commonly used variables
  common_identifier             = "platform-sandbox-platform-dev"
  network_terragrunter_role_arn = local.network_vars.terragrunter_role_arn
  infra_terragrunter_role_arn   = local.infra_vars.locals.terragrunter_role_arn
  terragrunter_external_id      = local.infra_vars.locals.terragrunter_external_id
  region                        = local.network_vars.region

  # Transit Gateway Non-Prod
  transit_gateway_id = local.vpn_vars.transit_gateway_id

  # Transit Gateway Attachment (Non-Prod)
  vpn_transit_gateway_attachment_id = local.vpn_vars.vpn_transit_gateway_attachment_id
  dso_transit_gateway_attachment_id = local.vpn_vars.dso_transit_gateway_attachment_id

  # Transit Gateway Route Table
  vpn_transit_gateway_route_table_id = local.vpn_vars.vpn_transit_gateway_route_table_id
  dso_transit_gateway_route_table_id = local.vpn_vars.dso_transit_gateway_route_table_id

  # common CIDR blocks (VPN and DSO)
  dso_cidr_block = local.vpn_vars.dso_cidr_block
  vpn_cidr_block = local.vpn_vars.vpn_cidr_block

  # VPC CIDR block
  vpc_cidr_block = "172.27.48.0/20"
}
