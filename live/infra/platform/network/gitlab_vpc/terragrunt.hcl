include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "vpn_vars" {
  path   = "../../vpn/vpn_vars.hcl"
  expose = true
}

terraform {
  source = "${get_repo_root()}/../modules//network/vpc"
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/vpc_flow_logs"
  mock_outputs = {
    cloudwatch_destination_arn = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
  }
}

inputs = {
  vpc_name                     = "dos-devsecops-vpc"
  vpc_cidr                     = include.vpn_vars.locals.dso_cidr_block
  log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
  availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
  # Forced ranges are used because the auto-assignment strategy would start at 16.0, not 16.1:
  force_subnet_cidr_ranges = {
    "us-east-1a" = "172.16.1.0/24",
    "us-east-1b" = "172.16.2.0/24",
    "us-east-1c" = "172.16.3.0/24",
  }
  interface_endpoints = [
    "ec2",
    "sts",
    "ecr.api",
    "ecr.dkr",
    "ec2messages",
    "elasticloadbalancing",
    "inspector2",
    "inspector-scan",
    "logs",
    "kms",
    "ssm",
    "ssm-incidents",
    "ssmmessages",
    # "ssm-contacts", - needs a different AZ
    "codeartifact.api",
    "codeartifact.repositories",
    "eks",
    "monitoring",
    "autoscaling",
    "secretsmanager",
  ]
}
