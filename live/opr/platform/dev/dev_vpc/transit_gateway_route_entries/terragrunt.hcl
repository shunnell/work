include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/transit_gateway_route_entry"
}

locals {
  dev_vpc_vars = read_terragrunt_config(find_in_parent_folders("dev_vpc.hcl"))
}

dependency "egress_vpc_transit_gateway_route_table" {
  config_path = "${get_repo_root()}/network/platform/non_prod_inspection_vpc/transit_gateway_route_table"
  mock_outputs = {
    transit_gateway_route_table_id = ""
  }
}

dependency "egress_vpc_transit_gateway_attachmment" {
  config_path = "${get_repo_root()}/network/platform/non_prod_inspection_vpc/transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = ""
  }
}

dependency "dso_vpc" {
  config_path = "${get_repo_root()}/infra/platform/network/gitlab_vpc"
  mock_outputs = {
    vpc_cidr_block = ""
  }
}

dependency "vpn_vpc" {
  config_path = "${get_repo_root()}/infra/platform/network/vpn_vpc"
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
    "../transit_gateway_attach_accept",
    "../transit_gateway_attach",
    "../vpc",
    "${get_repo_root()}/network/platform/non_prod_inspection_vpc/transit_gateway_route_table",
    "${get_repo_root()}/network/platform/non_prod_inspection_vpc/transit_gateway_attach",
  ]
}

inputs = {
  tgw_routes = {
    "vpc_to_nonprod_egress" = {
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      destination_cidr_block         = "0.0.0.0/0"
      transit_gateway_attachment_id  = dependency.egress_vpc_transit_gateway_attachmment.outputs.transit_gateway_attachment_id
    },
    "nonprod_egress_to_vpc" = {
      transit_gateway_route_table_id = dependency.egress_vpc_transit_gateway_route_table.outputs.transit_gateway_route_table_id
      destination_cidr_block         = local.dev_vpc_vars.locals.vpc_cidr_block
      transit_gateway_attachment_id  = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
    },
    "blackhole" = {
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      destination_cidr_block         = "172.16.0.0/12"
      blackhole                      = true
    },
    "vpc_to_vpn" = {
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      transit_gateway_attachment_id  = local.dev_vpc_vars.locals.vpn_transit_gateway_attachment_id
      destination_cidr_block         = dependency.vpn_vpc.outputs.vpc_cidr_block
    }
    "vpn_to_vpc" = {
      transit_gateway_route_table_id = local.dev_vpc_vars.locals.vpn_transit_gateway_route_table_id
      transit_gateway_attachment_id  = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
      destination_cidr_block         = local.dev_vpc_vars.locals.vpc_cidr_block
    }
    "vpc_to_dso" = {
      transit_gateway_route_table_id = dependency.transit_gateway_route_table.outputs.transit_gateway_route_table_id
      transit_gateway_attachment_id  = local.dev_vpc_vars.locals.dso_transit_gateway_attachment_id
      destination_cidr_block         = dependency.dso_vpc.outputs.vpc_cidr_block
    }
    "dso_to_vpc" = {
      transit_gateway_route_table_id = local.dev_vpc_vars.locals.dso_transit_gateway_route_table_id
      transit_gateway_attachment_id  = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
      destination_cidr_block         = local.dev_vpc_vars.locals.vpc_cidr_block
    }
  }
}

generate "provider_override" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "us-east-1"
      assume_role {
        role_arn = "${local.dev_vpc_vars.locals.network_terragrunter_role_arn}"
      }
    }
  EOF
}
