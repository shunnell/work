include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  destination_name = "MultiAccountEKSLogs"
  sourcetype       = "kube:audit"
}


dependency "shipper_substrate" {
  config_path = "../shipper_failure_storage"
  mock_outputs = {
    failed_shipments_s3_bucket_arn             = "bad/arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
    failed_shipments_cloudwatch_log_group_name = "bad/name"
  }
}

dependency "vpc" {
  config_path = "../../../dev/dev_vpc/vpc"
  mock_outputs = {
    private_subnets_by_az = {}
  }
}

dependency "account_list" {
  config_path = "${get_repo_root()}/management/platform/sso/utilities/account_list"
  mock_outputs = {
    accounts = {}
  }
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//monitoring/cloudwatch_log_shipping_destination"
}

inputs = {
  destination_name                           = local.destination_name
  log_sourcetype                             = local.sourcetype
  account_list_mapping                       = dependency.account_list.outputs.accounts
  failed_shipments_s3_bucket_arn             = dependency.shipper_substrate.outputs.failed_shipments_s3_bucket_arn
  failed_shipments_cloudwatch_log_group_name = dependency.shipper_substrate.outputs.failed_shipments_cloudwatch_log_group_name
  log_sender_aws_organization_path           = read_terragrunt_config("${get_path_to_repo_root()}/management/account.hcl").locals.bespin_organization_root_id
  vpc_subnet_ids                             = [for _, v in dependency.vpc.outputs.private_subnets_by_az : v.subnet_id]
}
