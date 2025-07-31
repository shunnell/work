include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("dev_vpc.hcl")).locals
}


terraform {
  source = "${get_repo_root()}/../modules//network/vpc"
}

# CloudWatch Log shipping  destination could cause recursive logging in same VPC, DO NOT SET !!!
# dependency cloudwatch_sharing_target was removed
# log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
# Remote endpoints disabled for this VPC to avoid transit gateway costs from high-volume logs API traffic

inputs = {
  vpc_name              = "data-platform-log-shipping-vpc"
  availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  gateway_endpoints     = []
  vpc_cidr              = local.vpc_vars.vpc_cidr_block
  create_public_subnets = false
  enable_dns_profile    = false
  interface_endpoints   = ["logs"]
}
