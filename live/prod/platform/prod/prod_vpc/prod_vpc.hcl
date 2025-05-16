locals {
  # Load common variables
  network_vars = read_terragrunt_config("${get_repo_root()}/network/account.hcl")
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract commonly used variables
  common_identifier = "${local.account_vars.locals.account}-shared"
  # Extract commonly used variables
  network_terragrunter_role_arn = local.network_vars.locals.terragrunter_role_arn
  bespin_cidr_block             = local.network_vars.locals.bespin_cidr_block
  region                        = local.network_vars.locals.region

  # Transit Gateway
  transit_gateway_id = "tgw-01b2f5518f95cff63"

  # Transit Gateway Attachment
  vpn_transit_gateway_attachment_id = "tgw-attach-06fe8415f714cd4d3"
  dso_transit_gateway_attachment_id = "tgw-attach-0135705a02b43dd9f"

  # Transit Gateway Route Table
  vpn_transit_gateway_route_table_id = "tgw-rtb-08505e9c3c632a9ea"
  dso_transit_gateway_route_table_id = "tgw-rtb-0ce4d419807280ee2"

  # vpc CIDR block
  vpc_cidr_block = "172.17.16.0/20"
}