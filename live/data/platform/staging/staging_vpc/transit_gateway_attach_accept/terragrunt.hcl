include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/transit_gateway_attach_accept"
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("staging_vpc.hcl")).locals
}

dependency "transit_gateway_attach" {
  config_path = "../transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = "mock-transit-gateway-attachment-id"
  }
}

dependencies {
  paths = ["../vpc", "../transit_gateway_attach"]
}

inputs = {
  transit_gateway_attachment_id = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
  tags = {
    Name = "${local.vpc_vars.common_identifier}-tgw-attach"
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

