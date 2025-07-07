include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/vpc"
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/vpc_flow_logs"
  mock_outputs = {
    cloudwatch_destination_arn = ""
  }
}

dependency "route53_profile" {
  config_path = "${get_path_to_repo_root()}/network/platform/route53"
  mock_outputs = {
    profile_id = ""
  }
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("vpc_vars.hcl"))

  # Extract commonly used variables
  common_identifier = local.vpc_vars.locals.common_identifier
  vpc_name          = local.vpc_vars.locals.vpc_name
  vpc_cidr_block    = local.vpc_vars.locals.vpc_cidr_block
}

inputs = {
  vpc_name                     = local.vpc_name
  block_public_access          = false
  vpc_cidr                     = local.vpc_cidr_block
  interface_endpoints          = []
  gateway_endpoints            = []
  availability_zones           = ["us-east-1a", "us-east-1b", "us-east-1c"]
  log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
  enable_dns_profile           = true
  custom_cidr_range            = null
  # profile_id                   = dependency.route53_profile.outputs.profile_id
}
