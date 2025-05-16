include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/transit_gateway_route_entry"
}

locals {
  # Load common variables
  admin_vpc_vars = read_terragrunt_config(find_in_parent_folders("admin_vpc.hcl")).locals

  # Extract commonly used variables
  vpn_transit_gateway_attachment_id = local.admin_vpc_vars.vpn_transit_gateway_attachment_id
  dso_transit_gateway_attachment_id = local.admin_vpc_vars.dso_transit_gateway_attachment_id
  vpn_cidr_block                    = local.admin_vpc_vars.vpn_cidr_block
  dso_cidr_block                    = local.admin_vpc_vars.dso_cidr_block
  network_terragrunter_role_arn     = local.admin_vpc_vars.network_terragrunter_role_arn
}

dependency "transit_gateway_route_table" {
  config_path = "../transit_gateway_route_table"
  mock_outputs = {
    transit_gateway_route_table_id = "mock-tgw-rtb-id"
  }
}

dependencies {
  paths = ["../transit_gateway_route_table", "../transit_gateway_attach_accept", "../vpc"]
}

inputs = {
  tgw_routes = {
    "blackhole" = {
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      destination_cidr_block         = "172.16.0.0/12"
      blackhole                      = true
    },
    "VPN" = { ## VPN Route
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      transit_gateway_attachment_id  = local.vpn_transit_gateway_attachment_id
      destination_cidr_block         = local.vpn_cidr_block
    }
    "DSO" = { ## DSO Route
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      transit_gateway_attachment_id  = local.dso_transit_gateway_attachment_id
      destination_cidr_block         = local.dso_cidr_block
    }
  }
}

generate "provider_override" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.admin_vpc_vars.network_region}"
      assume_role {
        role_arn = "${local.network_terragrunter_role_arn}"
      }
    }
  EOF
}