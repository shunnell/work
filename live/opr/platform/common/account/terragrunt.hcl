include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "baseline" {
  path = "${get_repo_root()}/_envcommon/platform/common/account/baseline.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//common/account/"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

## temporary for OPR to access secrets to remediate RED team issues PTTC 007
## We will remove this once we have a more permanent solution in place (Team Sandbox_dev permission_set)

inputs = {
  account_name = local.account_vars.account
}