include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules/network/vpc_route_table_entry"
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("vpc.hcl")).locals

  # Extract commonly used variables
  transit_gateway_id = local.vpc_vars.transit_gateway_id
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    private_subnets_by_az = {}
  }
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  routes = [for subnet in values(dependency.vpc.outputs.private_subnets_by_az) : {
    route_table_id         = subnet.route_table_id
    destination_cidr_block = "0.0.0.0/0"
    transit_gateway_id     = local.transit_gateway_id
  }]
}
