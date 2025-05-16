# Lets the logging account get a listing of other accounts in the org:
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Cross-Account-Cross-Region.html
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "logging_account" {
  path   = "${get_repo_root()}/logs/account.hcl"
  expose = true
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//monitoring/cloudwatch_log_sharing_management"
}

inputs = {
  monitoring_account_id = include.logging_account.locals.account_id
}
