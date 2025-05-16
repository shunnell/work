include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/vpc_route_table_entry"
}

locals {
  # Load common variables
  inspection_firewall_vars = read_terragrunt_config(find_in_parent_folders("prod_inspection_firewall.hcl"))

  # Extract commonly used variables
  bespin_cidr_block = local.inspection_firewall_vars.locals.bespin_cidr_block
}

dependency "network_firewall" {
  config_path = "../firewall"
  mock_outputs = {
    endpoint_ids = {
      "us-east-1a" = {
        endpoint_id = "mock-endpoint-id"
        subnet_id   = "mock-subnet-id"
      },
      "us-east-1b" = {
        endpoint_id = "mock-endpoint-id"
        subnet_id   = "mock-subnet-id"
      },
      "us-east-1c" = {
        endpoint_id = "mock-endpoint-id"
        subnet_id   = "mock-subnet-id"
      }
    }
  }
}

dependency "vpc" {
  config_path = "../../prod_inspection_vpc/vpc"
  mock_outputs = {
    private_subnets_by_az = {}
  }
}

dependency "public_subnets" {
  config_path = "../../prod_inspection_vpc/vpc/public_subnets"
  mock_outputs = {
    subnets = {}

  }
}

dependency "firewall_subnets" {
  config_path = "../../prod_inspection_vpc/vpc/firewall_subnets"
  mock_outputs = {
    subnets = {}
  }
}

inputs = {
  routes = flatten([
    # Public Inbound routes to the firewall
    [
      for az, subnet in dependency.public_subnets.outputs.subnets : {
        route_table_id         = subnet.route_table_id
        destination_cidr_block = local.bespin_cidr_block
        vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids[az].endpoint_id
    }],
    # Private Outbound routes to the firewall
    [
      for az, subnet in dependency.vpc.outputs.private_subnets_by_az : {
        route_table_id         = subnet.route_table_id
        destination_cidr_block = "0.0.0.0/0"
        vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids[az].endpoint_id
    }],
    # Public Outbound routes to the nat gateway
    [
      for az, subnet in dependency.firewall_subnets.outputs.subnets : {
        route_table_id         = subnet.route_table_id
        destination_cidr_block = "0.0.0.0/0"
        nat_gateway_id         = dependency.public_subnets.outputs.subnets[az].nat_gateway_id
    }],
  ])
}
