include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/network/custom_subnets"
}

locals {
  # Load common variables
  inspection_vpc_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_vpc.hcl"))

  # Extract commonly used variables
  common_identifier = local.inspection_vpc_vars.locals.common_identifier
  vpc_name          = local.inspection_vpc_vars.locals.vpc_name
  default_tags      = local.inspection_vpc_vars.locals.default_tags
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id         = "mock-vpc-id"
    public_subnets = ["mock-public-subnet-id-1", "mock-public-subnet-id-2", "mock-public-subnet-id-3"]
  }
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  vpc_name           = local.vpc_name
  subnet_name        = "firewall"
  type               = "private"
  create_nat_gateway = true
  nat_gateway_count  = 3
  public_subnets     = dependency.vpc.outputs.public_subnets
  subnets_config = [
    {
      az            = "us-east-1a"
      custom_subnet = "172.20.3.96/28"
    },
    {
      az            = "us-east-1b"
      custom_subnet = "172.20.3.112/28"
    },
    {
      az            = "us-east-1c"
      custom_subnet = "172.20.3.128/28"
    }
  ]

  tags = merge(local.default_tags, {
    name = "${local.common_identifier}-firewall-subnets"
  })
}
