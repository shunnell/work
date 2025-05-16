include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/transit_gateway_attach"
}

locals {
  # Load common variables
  admin_vpc_vars = read_terragrunt_config(find_in_parent_folders("admin_vpc.hcl")).locals

  # Extract commonly used variables
  common_identifier  = local.admin_vpc_vars.common_identifier
  transit_gateway_id = local.admin_vpc_vars.transit_gateway_id
}
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                = "mock-vpc-id"
    private_subnets_by_az = {}
  }
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  name               = "${local.common_identifier}-tgw-attach"
  transit_gateway_id = local.transit_gateway_id
  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = [for _, v in dependency.vpc.outputs.private_subnets_by_az : v.subnet_id]
  tags = {
    name = "${local.common_identifier}-tgw-attach"
  }
}




