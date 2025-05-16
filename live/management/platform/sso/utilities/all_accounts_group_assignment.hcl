# DRYs up the work needed to give an SSO group access to all AWS accounts via a permission set (for platform-wide
# user groups, e.g. administrators, security auditors).
# This file is meant to be included. To include it, two requirements must be met:
# 1. An adjacent ../permission_set terragrunt module.
# 2. An input 'group_display_name' defined which references an existent, SCIM-managed AWS SSO/IAMIDC group name.

terraform {
  source = "${get_path_to_repo_root()}/../modules//iam/sso_group_account_assignment"
}

dependency "permission_set" {
  config_path = "../permission_set"
  mock_outputs = {
    permission_set_arn = "arn:aws:sso:::permissionSet/mock-12345"
  }
}


dependency "account_list" {
  config_path = "${get_repo_root()}/management/platform/sso/utilities/account_list"
  mock_outputs = {
    accounts = { "1234" = "tenantname" }
  }
}

dependency "sso_instance" {
  # NOTE: This must be `get_repo_root` and NOT `get_path_to_repo_root` in order for this to
  # work with `expose = true` in includes. Expose = true changes the pathing such that the relative lookup
  # happens from a different place, this need to be pinned
  config_path = "${get_repo_root()}/management/platform/sso/utilities/sso_instance"
  mock_outputs = {
    arn               = "arn:aws:sso:::instance/mock123456"
    identity_store_id = "d-aaaaaaaaaa"
  }
}

inputs = {
  instance_arn                  = dependency.sso_instance.outputs.arn
  identity_store_id             = dependency.sso_instance.outputs.identity_store_id
  session_duration              = "PT1H"
  account_to_permission_set_map = { for v in keys(dependency.account_list.outputs.accounts) : v => dependency.permission_set.outputs.permission_set_arn }
}
