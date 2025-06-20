include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/transit_gateway_route_table"
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("ivv_vpc.hcl")).locals
}

dependency "transit_gateway_attach" {
  config_path = "../transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = "mock-transit-gateway-attachment-id"
  }
}

dependency "transit_gateway_attach_accept" {
  config_path  = "../transit_gateway_attach_accept"
  skip_outputs = true
}

dependencies {
  paths = ["../transit_gateway_attach_accept", "../transit_gateway_attach", "../vpc"]
}

inputs = {
  transit_gateway_id            = local.vpc_vars.transit_gateway_id
  name                          = "${local.vpc_vars.common_identifier}-tgw-rt"
  transit_gateway_attachment_id = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
  tags = {
    name = "${local.vpc_vars.common_identifier}-tgw-rt"
  }
}

generate "provider-network" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.vpc_vars.region}"
      assume_role {
        role_arn = "${local.vpc_vars.network_terragrunter_role_arn}"
      }
    }
  EOF
}
