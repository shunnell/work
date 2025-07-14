locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

# Invokes the monitoring/tenant_baseline module with appropriate data supplied from dependencies in the log management
# account; see that module's README for more information.
dependency "cloudwatch_oam_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/cloudwatch_sharing"
  mock_outputs = {
    logging_account_oam_sink_id = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
  }
}

dependency "baseline_destinations" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/tenant_baseline_destinations"
  mock_outputs = {
    service_to_destination_arn = { "nonexistent_" = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7" }
  }
}

inputs = {
  account_name                                = local.account_vars.account
  eventbridge_service_name_to_destination_arn = dependency.baseline_destinations.outputs.service_to_destination_arn
  oam_sink_id                                 = dependency.cloudwatch_oam_sharing_target.outputs.logging_account_oam_sink_id
}
