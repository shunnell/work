include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules/network/transit_gateway_route_entry"
}

locals {
  # Load common variables
  admin_vpc_vars = read_terragrunt_config(find_in_parent_folders("admin_vpc.hcl")).locals

  # Extract commonly used variables
  vpn_transit_gateway_route_table_id = local.admin_vpc_vars.vpn_transit_gateway_route_table_id
  vpc_cidr_block                     = local.admin_vpc_vars.vpc_cidr_block
  network_terragrunter_role_arn      = local.admin_vpc_vars.network_terragrunter_role_arn
}

dependency "transit_gateway_attach" {
  config_path = "../transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = "mock-tgw-att-id"
  }
}

dependencies {
  paths = ["../transit_gateway_attach_accept", "../transit_gateway_attach", "../vpc"]
}
inputs = {
  tgw_routes = {
    "vpn_route" = {
      transit_gateway_route_table_id = local.vpn_transit_gateway_route_table_id
      transit_gateway_attachment_id  = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
      destination_cidr_block         = local.vpc_cidr_block
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
