include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/vpc"
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("prod_vpc.hcl"))

  # Extract commonly used variables
  common_identifier = local.vpc_vars.locals.common_identifier
  vpc_cidr_block    = local.vpc_vars.locals.vpc_cidr_block
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/vpc_flow_logs"
  mock_outputs = {
    cloudwatch_destination_arn = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
  }
}

inputs = {
  vpc_name                     = local.common_identifier
  vpc_cidr                     = local.vpc_cidr_block
  availability_zones           = ["us-east-1a", "us-east-1b", "us-east-1c"]
  log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
}
