locals {
  # Load common variables
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  platform_vars = read_terragrunt_config(find_in_parent_folders("team.hcl")).locals
  vpn_vars      = read_terragrunt_config("${get_repo_root()}/infra/platform/vpn/vpn_vars.hcl").locals

  # Extract commonly used variables
  common_identifier = "${local.account_vars.account}-shared-services"
  vpc_name          = "${local.common_identifier}-vpc"

  # Transit Gateway
  transit_gateway_id = local.vpn_vars.transit_gateway_id

  # Transit Gateway Attachment
  vpn_transit_gateway_attachment_id = local.vpn_vars.vpn_transit_gateway_attachment_id
  dso_transit_gateway_attachment_id = local.vpn_vars.dso_transit_gateway_attachment_id

  # Transit Gateway Route Table
  vpn_transit_gateway_route_table_id = local.vpn_vars.vpn_transit_gateway_route_table_id
  dso_transit_gateway_route_table_id = local.vpn_vars.dso_transit_gateway_route_table_id

  # common CIDR blocks (VPN and DSO)
  dso_cidr_block = local.vpn_vars.dso_cidr_block
  vpn_cidr_block = local.vpn_vars.vpn_cidr_block

  # vpc CIDR block
  vpc_cidr_block = "172.20.32.0/20"
}