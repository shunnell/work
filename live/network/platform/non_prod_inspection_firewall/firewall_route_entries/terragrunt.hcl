include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/vpc_route_table_entry"
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
  config_path = "../../non_prod_inspection_vpc/vpc"
  mock_outputs = {
    private_subnets_by_az = {}
  }
}

dependency "public_subnets" {
  config_path = "../../non_prod_inspection_vpc/vpc/public_subnets"
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
        destination_cidr_block = "172.16.0.0/12"
        vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids[az].endpoint_id
    }],
    # Private Outbound routes to the firewall
    [
      for az, subnet in dependency.vpc.outputs.private_subnets_by_az : {
        route_table_id         = subnet.route_table_id
        destination_cidr_block = "0.0.0.0/0"
        vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids[az].endpoint_id
    }],
  ])
}

