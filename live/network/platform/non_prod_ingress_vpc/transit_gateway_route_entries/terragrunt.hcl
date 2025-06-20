include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules/network/transit_gateway_route_entry"
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("vpc_vars.hcl")).locals
}

dependency "shared_services_transit_gateway_attach" {
  config_path = "${get_repo_root()}/network/platform/shared_services_vpc/transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = ""
  }
}

dependency "shared_services_transit_gateway_route_table" {
  config_path = "${get_repo_root()}/network/platform/shared_services_vpc/transit_gateway_route_table"
  mock_outputs = {
    transit_gateway_route_table_id = ""
  }
}

dependency "shared_services_vpc" {
  config_path = "${get_repo_root()}/network/platform/shared_services_vpc/vpc"
  mock_outputs = {
    vpc_cidr_block = ""
  }
}

dependency "transit_gateway_route_table" {
  config_path = "../transit_gateway_route_table"
  mock_outputs = {
    transit_gateway_route_table_id = ""
  }
}

dependency "transit_gateway_attach" {
  config_path = "../transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = ""
  }
}

dependencies {
  paths = [
    "../transit_gateway_route_table",
    "../vpc",
    "${get_repo_root()}/network/platform/shared_services_vpc/transit_gateway_attach",
    "${get_repo_root()}/network/platform/shared_services_vpc/transit_gateway_route_table",
    "${get_repo_root()}/network/platform/shared_services_vpc/vpc"
  ]
}

inputs = {
  tgw_routes = {
    # Blackhole Route
    "blackhole" = {
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      destination_cidr_block         = "172.16.0.0/12"
      blackhole                      = true
    }
    # Shared Services Routes
    "vpc_to_shared_services" = {
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      transit_gateway_attachment_id  = dependency.shared_services_transit_gateway_attach.outputs.transit_gateway_attachment_id
      destination_cidr_block         = dependency.shared_services_vpc.outputs.vpc_cidr_block
    }
    "shared_services_to_vpc" = {
      transit_gateway_route_table_id = dependency.shared_services_transit_gateway_route_table.outputs.transit_gateway_route_table_id
      transit_gateway_attachment_id  = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
      destination_cidr_block         = local.vpc_vars.vpc_cidr_block
    }
  }
}
