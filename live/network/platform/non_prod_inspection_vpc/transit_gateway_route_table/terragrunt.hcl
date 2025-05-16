include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules/network/transit_gateway_route_table"
}

locals {
  # Load common variables
  inspection_vpc_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_vpc.hcl"))

  # Extract commonly used variables
  common_identifier  = local.inspection_vpc_vars.locals.common_identifier
  transit_gateway_id = local.inspection_vpc_vars.locals.transit_gateway_id
}

dependency "transit_gateway_attach" {
  config_path = "../transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = "mock-transit-gateway-attachment-id"
  }
}

dependencies {
  paths = ["../transit_gateway_attach", "../vpc"]
}

inputs = {
  transit_gateway_id            = local.transit_gateway_id
  name                          = "${local.common_identifier}-tgw-rt"
  transit_gateway_attachment_id = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
  tags = {
    name = "${local.common_identifier}-tgw-rt"
  }
}


