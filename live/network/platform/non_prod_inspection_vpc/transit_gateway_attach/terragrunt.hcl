include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/network/transit_gateway_attach"
}

locals {
  # Load common variables
  inspection_vpc_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_vpc.hcl"))

  # Extract commonly used variables
  common_identifier  = local.inspection_vpc_vars.locals.common_identifier
  transit_gateway_id = local.inspection_vpc_vars.locals.transit_gateway_id
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


