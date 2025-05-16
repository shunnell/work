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
    permission_set_arn = "arn:aws:sso:::permissionSet/mock-12345"
  }
}

dependency "opr_observer" {
  config_path = "../../permission_sets/OPR_Observer"
  mock_outputs = {
    permission_set_arn = "arn:aws:sso:::permissionSet/mock-12345"
  }
}

dependency "opr_dev_infra" {
  config_path = "../../permission_sets/OPR_Dev_Infra"
  mock_outputs = {
    permission_set_arn = "arn:aws:sso:::permissionSet/mock-12345"
  }
}

locals {
  tenant_account_id = read_terragrunt_config("${get_repo_root()}/opr/account.hcl").locals.account_id
  infra_account_id  = read_terragrunt_config("${get_repo_root()}/infra/account.hcl").locals.account_id
  prod_account_id   = read_terragrunt_config("${get_repo_root()}/prod/account.hcl").locals.account_id
}

inputs = {
  account_to_permission_set_map = {
    (local.tenant_account_id) = dependency.sandbox_dev.outputs.permission_set_arn
    (local.infra_account_id)  = dependency.opr_dev_infra.outputs.permission_set_arn
    (local.prod_account_id)   = dependency.opr_observer.outputs.permission_set_arn
  }
  group_display_name = "Cloud City OPR DevSecOps Enterprise Users"
}