// Start: Standard "Group Account Assignment" boilerplate
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "sso_resource" {
  path = "${get_path_to_repo_root()}/management/platform/sso/utilities/sso_resource.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//iam/sso_group_account_assignment"
}
// END

dependency "sandbox_dev" {
  config_path = "${get_path_to_repo_root()}/management/platform/sso/shared/permission_sets/Sandbox_Dev"
  mock_outputs = {
    permission_set_arn = "arn:aws:sso:::permissionSet/mock/Sandbox_Dev"
  }
}

dependency "observer" {
  config_path = "../../permission_sets/Observer"
  mock_outputs = {
    permission_set_arn = "arn:aws:sso:::permissionSet/mock/Observer"
  }
}

locals {
  tenant_account_id = read_terragrunt_config("${get_repo_root()}/data/account.hcl").locals.account_id
  prod_account_id   = read_terragrunt_config("${get_repo_root()}/prod/account.hcl").locals.account_id
}

inputs = {
  group_display_name = "Cloud City Data-Platform Developer Enterprise Users"
  account_to_permission_set_map = tomap({
    (local.tenant_account_id) = dependency.sandbox_dev.outputs.permission_set_arn
    (local.prod_account_id)   = dependency.observer.outputs.permission_set_arn
  })
}