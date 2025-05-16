include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/network_firewall"
  mock_outputs = {
    cloudwatch_destination_arn = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
  }
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//monitoring/cloudwatch_log_shipping_source"
}

inputs = {
  destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
  log_group_arns = [
    "arn:aws:logs:${include.account.locals.region}:${include.account.locals.account_id}:/aws/network-firewall/network-platform-non-prod-inspection/flow",
    "arn:aws:logs:${include.account.locals.region}:${include.account.locals.account_id}:/aws/network-firewall/network-platform-non-prod-inspection/alert",
    "arn:aws:logs:${include.account.locals.region}:${include.account.locals.account_id}:/aws/network-firewall/network-platform-non-prod-inspection/tls"

  ]
}

