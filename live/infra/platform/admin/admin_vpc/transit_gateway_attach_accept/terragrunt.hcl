include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules/network/transit_gateway_attach_accept"
}

locals {
  # Load common variables
  admin_vpc_vars = read_terragrunt_config(find_in_parent_folders("admin_vpc.hcl")).locals

  # Extract commonly used variables
  common_identifier             = local.admin_vpc_vars.common_identifier
  network_terragrunter_role_arn = local.admin_vpc_vars.network_terragrunter_role_arn
}
dependency "transit_gateway_attach" {
  config_path = "../transit_gateway_attach"
  mock_outputs = {
    transit_gateway_attachment_id = "mock-transit-gateway-attachment-id"
  }
}

dependencies {
  paths = ["../transit_gateway_attach", "../vpc"]
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
      region = "${local.admin_vpc_vars.network_region}"
      assume_role {
        role_arn = "${local.network_terragrunter_role_arn}"
      }
    }
  EOF
}
