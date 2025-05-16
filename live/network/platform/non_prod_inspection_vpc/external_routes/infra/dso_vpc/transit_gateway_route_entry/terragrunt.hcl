include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/network/transit_gateway_route_entry"
}

locals {
  # Load common variables
  routes_vars = read_terragrunt_config(find_in_parent_folders("dso_vpc.hcl"))

  # Extract commonly used variables
  vpc_cidr_block                = local.routes_vars.locals.vpc_cidr_block
  transit_gateway_attachment_id = local.routes_vars.locals.transit_gateway_attachment_id
}

dependency "transit_gateway_route_table" {
  config_path = find_in_parent_folders("transit_gateway_route_table")
  mock_outputs = {
    transit_gateway_route_table_id = "mock-tgw-rtb-id"
  }
}

inputs = {
  tgw_routes = {
    "egress-route" = {
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      transit_gateway_attachment_id  = local.transit_gateway_attachment_id
      destination_cidr_block         = local.vpc_cidr_block
    }
  }
}

