include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/../modules//monitoring/cloudwatch_log_shipping_failure_storage"
}

inputs = {
  name = "cloudcity-splunk-shipper-failures"
}
