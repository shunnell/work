locals {
  # Load common variables
  admin_vars   = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
  network_vars = read_terragrunt_config("${get_path_to_repo_root()}/network/account.hcl")

  # Extract commonly used variables
  common_identifier             = local.admin_vars.locals.common_identifier
  vpc_name                      = "${local.common_identifier}-test-vpc23-us-east-1"
  network_terragrunter_role_arn = local.network_vars.locals.terragrunter_role_arn
  network_region                = local.network_vars.locals.region

  # Transit Gateway Non-Prod
  transit_gateway_id = "tgw-0e789e42aaa2beb19"

  # Transit Gateway Attachment (Non-Prod)
  dso_transit_gateway_attachment_id = "tgw-attach-07ed5cbe1d23892dd"

  # Transit Gateway Route Table
  dso_transit_gateway_route_table_id = "tgw-rtb-0c3eaa48975afd797"

  # common CIDR blocks (VPN and DSO)
  dso_cidr_block = "172.16.0.0/16"

  # VPC CIDR block
  vpc_cidr_block = "172.23.16.0/20"
}