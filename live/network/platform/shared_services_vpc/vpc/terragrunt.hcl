include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//network/vpc"
}

locals {
  # Load common variables
  vpc_vars = read_terragrunt_config(find_in_parent_folders("shared_services_vpc.hcl"))

  # Extract commonly used variables
  vpc_name       = local.vpc_vars.locals.vpc_name
  vpc_cidr_block = local.vpc_vars.locals.vpc_cidr_block
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/vpc_flow_logs"
  mock_outputs = {
    cloudwatch_destination_arn = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
  }
}

inputs = {
  vpc_name                     = local.vpc_name
  vpc_cidr                     = local.vpc_cidr_block
  availability_zones           = ["us-east-1a", "us-east-1b", "us-east-1c"]
  log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
  interface_endpoints = [
    # Most of these are required by NIST-800-53 compliance scans.
    # The remainder are useful often enough that it's worth configuring them everywhere.
    "ec2",
    "ec2messages",
    "ecr.api",
    "ecr.dkr",
    "eks",
    "elasticloadbalancing",
    "guardduty-data",
    "inspector-scan",
    "inspector2",
    "kms",
    "logs",
    "rds",
    "secretsmanager",
    # "ssm-contacts", -- unavailable in some AZs, pending AWS ticket to resolve
    "ssm-incidents",
    "ssm",
    "ssmmessages",
    "sts",
    "xray",
    "events",
  ]
  # Disable DNS profile to allow the creation of the VPC endpoints.
  enable_dns_profile = false
  # Custom CIDR range for the VPC endpoints security group rule used for shared services vpc to allow all workloads within Bespin to access the shared services vpc
  custom_cidr_range = "172.16.0.0/12"
}