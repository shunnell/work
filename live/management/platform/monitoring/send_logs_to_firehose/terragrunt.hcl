include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

# TODO after log shipping is more firmed up, and destinations are shared by stream data format (e.g. one destination
#   for CloudWatch, regardless of the source), this code can be rolled up into the tenant logging baseline module, and
#   custom/non-baseline-related log ARNs can be passed into that module for shipment.
dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/cloudtrail"
  mock_outputs = {
    cloudwatch_destination_arn = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
  }
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//monitoring/cloudwatch_log_shipping_source"
}

inputs = {
  destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
  # Created externally; this should be changed (in name and location) and eventually passed as an output once we
  # manage CloudTrail in terraform. At the moment, doing it as a data variable or another retrieval strategy doesn't
  # buy us anything; this module would fail to apply if it stopped existing anyway.
  # TODO centrally manage CloudTrail logging (and, if possible, have the logs themselves be stored in the Log Archive
  #   account; the management account should just set the policy, not also store the logs.
  log_group_arns = ["arn:aws:logs:${include.account.locals.region}:${include.account.locals.account_id}:log-group:aws-controltower/CloudTrailLogs"]
}
