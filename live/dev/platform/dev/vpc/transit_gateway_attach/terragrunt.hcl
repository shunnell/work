include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/transit_gateway_attach"
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("vpc.hcl")).locals
}

dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

inputs = {
  name               = "${local.vpc_vars.common_identifier}-tgw-attach"
  transit_gateway_id = local.vpc_vars.transit_gateway_id
  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = [for _, v in dependency.vpc.outputs.private_subnets_by_az : v.subnet_id]
  tags = {
    name = "${local.vpc_vars.common_identifier}-tgw-attach"
  }
}




