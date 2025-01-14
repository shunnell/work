include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/network/vpc"
}

locals {
  # Load common variables
  inspection_vpc_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_vpc.hcl"))

  # Extract commonly used variables
  common_identifier = local.inspection_vpc_vars.locals.common_identifier
  vpc_name          = local.inspection_vpc_vars.locals.vpc_name
  default_tags      = local.inspection_vpc_vars.locals.default_tags
}

# Dependencies
dependency "flow_logs_group" {
  config_path = "../flow_logs_group"

  mock_outputs = {
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:mock"
  }
}

dependency "flow_logs_iam_role" {
  config_path = "../flow_logs_iam/role"

  mock_outputs = {
    role_arn = "arn:aws:iam::123456789012:role/mock-role"
  }
}

inputs = {
  vpc_name = local.vpc_name
  vpc_cidr = "172.20.3.0/24"

  # Availability Zones
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # Subnet Configuration
  private_subnets = ["172.20.3.0/28", "172.20.3.16/28", "172.20.3.32/28"]
  public_subnets  = ["172.20.3.48/28", "172.20.3.64/28", "172.20.3.80/28"]

  # Feature flags
  create_private_subnets = true
  create_public_subnets  = true
  create_nat_gateway     = true
  create_igw             = true
  nat_gateway_count      = 0
  enable_dns_hostnames   = true
  enable_dns_support     = true

  # VPC Flow Logs
  enable_flow_logs          = true
  flow_logs_destination_arn = dependency.flow_logs_group.outputs.cloudwatch_log_group_arn
  flow_logs_traffic_type    = "ALL"
  flow_logs_role_arn        = dependency.flow_logs_iam_role.outputs.role_arn

  # Tags
  tags = merge(local.default_tags, {
    identifier = local.common_identifier
    vpc_name   = local.vpc_name
  })
}
