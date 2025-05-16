include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/transit_gateway_route_table"
}

locals {
  # Load common variables
  dev_vpc_vars = read_terragrunt_config(find_in_parent_folders("dev_vpc.hcl"))

  # Extract commonly used variables
  common_identifier             = local.dev_vpc_vars.locals.common_identifier
  transit_gateway_id            = local.dev_vpc_vars.locals.transit_gateway_id
  network_terragrunter_role_arn = local.dev_vpc_vars.locals.network_terragrunter_role_arn
  network_region                = local.dev_vpc_vars.locals.network_region
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
  transit_gateway_id            = local.transit_gateway_id
  name                          = "${local.common_identifier}-tgw-rt"
  transit_gateway_attachment_id = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
  tags = {
    name = "${local.common_identifier}-tgw-rt"
  }
}

generate "provider-network" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.network_region}"
      assume_role {
        role_arn = "${local.network_terragrunter_role_arn}"
      }
    }
  EOF
}
