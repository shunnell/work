locals {
  # Load common variables
  admin_vars   = read_terragrunt_config(find_in_parent_folders("dev.hcl")).locals
  network_vars = read_terragrunt_config("${get_path_to_repo_root()}/network/account.hcl").locals
  vpn_vars     = read_terragrunt_config("${get_path_to_repo_root()}/infra/platform/vpn/vpn_vars.hcl").locals

  # Extract commonly used variables
  common_identifier             = local.admin_vars.common_identifier
  network_terragrunter_role_arn = local.network_vars.terragrunter_role_arn
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
  vpc_cidr_block = "172.29.0.0/20"
}