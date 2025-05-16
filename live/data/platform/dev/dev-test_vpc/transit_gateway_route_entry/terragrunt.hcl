include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/transit_gateway_route_entry"
}

locals {
  # Load common variables
  dev_vpc_vars = read_terragrunt_config(find_in_parent_folders("dev_vpc.hcl"))

  # Extract commonly used variables
  dso_transit_gateway_attachment_id = local.dev_vpc_vars.locals.dso_transit_gateway_attachment_id
  dso_cidr_block                    = local.dev_vpc_vars.locals.dso_cidr_block
  network_terragrunter_role_arn     = local.dev_vpc_vars.locals.network_terragrunter_role_arn
  network_region                    = local.dev_vpc_vars.locals.network_region
}

dependency "transit_gateway_route_table" {
  config_path = "../transit_gateway_route_table"
  mock_outputs = {
    transit_gateway_route_table_id = "mock-tgw-rtb-id"
  }
}

dependencies {
  paths = ["../transit_gateway_route_table", "../transit_gateway_attach_accept", "../transit_gateway_attach", "../vpc"]
}

inputs = {
  tgw_routes = {
    "blackhole" = {
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      destination_cidr_block         = "172.16.0.0/12"
      blackhole                      = true
    },
    "DSO" = { ## DSO Route
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      transit_gateway_attachment_id  = local.dso_transit_gateway_attachment_id
      destination_cidr_block         = local.dso_cidr_block
    }
  }
}

generate "provider-network" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.network_region}"
      assume_role {
        role_arn = "${local.network_terragrunter_role_arn}"
      }
    }
  EOF
}
