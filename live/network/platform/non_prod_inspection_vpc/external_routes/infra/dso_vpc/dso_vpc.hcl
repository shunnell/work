locals {
  inspection_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_vpc.hcl"))

  # Load common variables
  common_identifier  = local.inspection_vars.locals.common_identifier
  transit_gateway_id = local.inspection_vars.locals.transit_gateway_id

  # Transit Gateway Attachment ID
  vpc_cidr_block                = "172.16.0.0/16"
  transit_gateway_attachment_id = "tgw-attach-07ed5cbe1d23892dd"

}
