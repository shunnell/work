locals {
  inspection_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_vpc.hcl"))
  infra_account   = read_terragrunt_config("${get_path_to_repo_root()}/infra/platform/vpn/vpn_vars.hcl").locals

  # Load common variables
  common_identifier  = local.inspection_vars.locals.common_identifier
  transit_gateway_id = local.inspection_vars.locals.transit_gateway_id

  # Transit Gateway Attachment ID
  vpc_cidr_block                = local.infra_account.dso_cidr_block
  transit_gateway_attachment_id = "tgw-attach-07ed5cbe1d23892dd"

}
