include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/vpc_route_table_entry"
}

locals {
  vpc_vars = read_terragrunt_config(find_in_parent_folders("prod_vpc.hcl"))
  region   = local.vpc_vars.locals.region
}

dependency "firewall_subnets" {
  config_path = "${get_repo_root()}/network/platform/prod_inspection_vpc/vpc/firewall_subnets"
  mock_outputs = {
    subnets = {}
  }
}

inputs = {
  routes = [for subnet in values(dependency.firewall_subnets.outputs.subnets) : {
    route_table_id         = subnet.route_table_id
    destination_cidr_block = local.vpc_vars.locals.vpc_cidr_block
    transit_gateway_id     = local.vpc_vars.locals.transit_gateway_id
  }]
}

generate "provider_override" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.vpc_vars.locals.region}"
      assume_role {
        role_arn = "${local.vpc_vars.locals.network_terragrunter_role_arn}"
      }
    }
  EOF
}
