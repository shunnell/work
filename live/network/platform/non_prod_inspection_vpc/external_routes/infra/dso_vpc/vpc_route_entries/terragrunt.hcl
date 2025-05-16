include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/network/vpc_route_table_entry"
}

locals {
  # Load common variables
  routes_vars = read_terragrunt_config(find_in_parent_folders("dso_vpc.hcl"))

  # Extract commonly used variables
  transit_gateway_id = local.routes_vars.locals.transit_gateway_id
  vpc_cidr_block     = local.routes_vars.locals.vpc_cidr_block
}

dependency "firewall_subnets" {
  config_path = "../../../../vpc/firewall_subnets"
  mock_outputs = {
    subnets = {}
  }
}

inputs = {
  routes = [for subnet in values(dependency.firewall_subnets.outputs.subnets) : {
    route_table_id         = subnet.route_table_id
    destination_cidr_block = local.vpc_cidr_block
    transit_gateway_id     = local.transit_gateway_id
  }]
}



