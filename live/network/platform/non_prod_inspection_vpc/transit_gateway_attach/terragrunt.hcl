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
  common_identifier = local.inspection_vpc_vars.locals.common_identifier
  default_tags      = local.inspection_vpc_vars.locals.default_tags
}
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id          = "mock-vpc-id"
    private_subnets = ["mock-private-subnet-id-1", "mock-private-subnet-id-2", "mock-private-subnet-id-3"]
  }
}

inputs = {
  name               = "${local.common_identifier}-tgw-attach"
  transit_gateway_id = "tgw-0e789e42aaa2beb19"
  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = dependency.vpc.outputs.private_subnets
  tags = merge(local.default_tags, {
    name = "${local.common_identifier}-tgw-attach"
  })
}


