locals {
  # Load common variables
  network_vars = read_terragrunt_config("${get_repo_root()}/network/account.hcl")
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract commonly used variables
  common_identifier = "${local.account_vars.locals.account}-dev"
  # Extract commonly used variables
  vpc_name                      = "${local.common_identifier}-vpc"
  network_terragrunter_role_arn = local.network_vars.locals.terragrunter_role_arn

  # Transit Gateway
  transit_gateway_id = "tgw-0e789e42aaa2beb19"

  # Transit Gateway Attachment
  vpn_transit_gateway_attachment_id = "tgw-attach-02fb4b2693de974c7"
  dso_transit_gateway_attachment_id = "tgw-attach-07ed5cbe1d23892dd"

  # Transit Gateway Route Table
  vpn_transit_gateway_route_table_id = "tgw-rtb-05ef4de680a3ff044"
  dso_transit_gateway_route_table_id = "tgw-rtb-0c3eaa48975afd797"

  # vpc CIDR block
  vpc_cidr_block = "172.29.0.0/20"
}