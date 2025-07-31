include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules/network/transit_gateway_route_table"
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("dev_vpc.hcl")).locals
}

dependency "transit_gateway_attach" {
  config_path = "../transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = "mock-transit-gateway-attachment-id"
  }
}

dependencies {
  paths = [
    "../transit_gateway_attach_accept",
    "../vpc"
  ]
}

inputs = {
  transit_gateway_id            = local.vpc_vars.transit_gateway_id
  name                          = "${local.vpc_vars.common_identifier}-tgw-rt"
  transit_gateway_attachment_id = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
  tags = {
    name = "${local.vpc_vars.common_identifier}-tgw-rt"
  }
}

generate "provider_override" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.vpc_vars.region}"
      assume_role {
        role_arn = "${local.vpc_vars.infra_terragrunter_role_arn}"
        external_id = "${local.vpc_vars.terragrunter_external_id}"
      }
      assume_role {
        role_arn = "${local.vpc_vars.network_terragrunter_role_arn}"
        external_id = "${local.vpc_vars.terragrunter_external_id}"
      }
    }
  EOF
}
