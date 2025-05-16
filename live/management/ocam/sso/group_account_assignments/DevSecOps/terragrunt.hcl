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

dependency "devsecops" {
  config_path = "../../permission_sets/DevSecOps"
  mock_outputs = {
    permission_set_arn = "arn:aws:sso:::permissionSet/mock/DevSecOps"
  }
}

dependency "devsecops_infra" {
  config_path = "../../permission_sets/DevSecOps_Infra"
  mock_outputs = {
    permission_set_arn = "arn:aws:sso:::permissionSet/mock/DevSecOps_Infra"
  }
}

locals {
  tenant_account_id = read_terragrunt_config("${get_repo_root()}/ocam/account.hcl").locals.account_id
  infra_account_id  = read_terragrunt_config("${get_repo_root()}/infra/account.hcl").locals.account_id
  prod_account_id   = read_terragrunt_config("${get_repo_root()}/prod/account.hcl").locals.account_id
}

inputs = {
  group_display_name = "Cloud City OCAM DevSecOps Enterprise Users"
  account_to_permission_set_map = tomap({
    (local.tenant_account_id) = dependency.sandbox_dev.outputs.permission_set_arn
    (local.infra_account_id)  = dependency.devsecops_infra.outputs.permission_set_arn
    (local.prod_account_id)   = dependency.devsecops.outputs.permission_set_arn
  })
}
