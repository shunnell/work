include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/transit_gateway_attach_accept"
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("prod_vpc.hcl"))

  # Extract commonly used variables
  common_identifier             = local.vpc_vars.locals.common_identifier
  network_terragrunter_role_arn = local.vpc_vars.locals.network_terragrunter_role_arn
  region                        = local.vpc_vars.locals.region
}

dependency "transit_gateway_attach" {
  config_path = "../transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = "mock-transit-gateway-attachment-id"
  }
}

dependencies {
  paths = [
    "../transit_gateway_attach", "../vpc"
  ]
}

inputs = {
  transit_gateway_attachment_id = dependency.transit_gateway_attach.outputs.transit_gateway_attachment_id
  tags = {
    Name = "${local.common_identifier}-tgw-attach"
  }
}

generate "provider_override" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.vpc_vars.locals.region}"
      assume_role {
        role_arn = "${local.network_terragrunter_role_arn}"
      }
    }
  EOF
}
