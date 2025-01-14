include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/network/route_table_entry"
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
    public_route_table_ids  = ["mock-public-route-table-id-1", "mock-public-route-table-id-2", "mock-public-route-table-id-3"]
    private_route_table_ids = ["mock-private-route-table-id-1", "mock-private-route-table-id-2", "mock-private-route-table-id-3"]
  }
}

inputs = {
  routes = [
    # Public Inbound routes to the firewall
    {
      route_table_id         = dependency.vpc.outputs.public_route_table_ids[0]
      destination_cidr_block = "172.16.0.0/12"
      vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids["us-east-1a"].endpoint_id
    },
    {
      route_table_id         = dependency.vpc.outputs.public_route_table_ids[1]
      destination_cidr_block = "172.16.0.0/12"
      vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids["us-east-1b"].endpoint_id
    },
    {
      route_table_id         = dependency.vpc.outputs.public_route_table_ids[2]
      destination_cidr_block = "172.16.0.0/12"
      vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids["us-east-1c"].endpoint_id
    },
    # Private Outbound routes to the firewall
    {
      route_table_id         = dependency.vpc.outputs.private_route_table_ids[0]
      destination_cidr_block = "0.0.0.0/0"
      vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids["us-east-1a"].endpoint_id
    },
    {
      route_table_id         = dependency.vpc.outputs.private_route_table_ids[1]
      destination_cidr_block = "0.0.0.0/0"
      vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids["us-east-1b"].endpoint_id
    },
    {
      route_table_id         = dependency.vpc.outputs.private_route_table_ids[2]
      destination_cidr_block = "0.0.0.0/0"
      vpc_endpoint_id        = dependency.network_firewall.outputs.endpoint_ids["us-east-1c"].endpoint_id
    }
  ]
}

