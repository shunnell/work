include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/iam/role"
}

locals {
  # Load common variables
  inspection_vpc_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_vpc.hcl"))

  # Extract commonly used variables
  common_identifier = local.inspection_vpc_vars.locals.common_identifier
  default_tags      = local.inspection_vpc_vars.locals.default_tags
}

dependency "flow_logs_policy" {
  config_path = "../policy"
  mock_outputs = {
    policy_arn = "arn:aws:iam::381492150796:policy/flow-logs-policy"
  }
}

inputs = {
  role_name   = "${local.common_identifier}-flow-logs-role"
  policy_json = file("${get_path_to_repo_root()}/_envcommon/platform/gitops/iam/vpc_flow_logs_role/trust_policy.json")
  policy_arns = [dependency.flow_logs_policy.outputs.policy_arn]
  tags = merge(local.default_tags, {
    name = "${local.common_identifier}-flow-logs-role"
  })
}


