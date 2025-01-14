include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/iam/policy"
}

locals {
  # Load common variables
  inspection_vpc_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_vpc.hcl"))

  # Extract commonly used variables
  common_identifier = local.inspection_vpc_vars.locals.common_identifier
  default_tags      = local.inspection_vpc_vars.locals.default_tags
}

dependency "flow_logs_group" {
  config_path = "../../flow_logs_group"
  mock_outputs = {
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:mock"
  }
}

inputs = {
  policy_name = "${local.common_identifier}-flow-logs-policy"
  policy_json = replace(file("${get_path_to_repo_root()}/_envcommon/platform/gitops/iam/vpc_flow_logs_role/flow_logs_policy.json"), "FLOW_LOGS_GROUP_ARN", dependency.flow_logs_group.outputs.cloudwatch_log_group_arn)
  tags = merge(local.default_tags, {
    name = "${local.common_identifier}-flow-logs-policy"
  })
}
