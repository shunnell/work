include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "account_list" {
  config_path = "${get_repo_root()}/management/platform/sso/utilities/account_list"
  mock_outputs = {
    accounts = {}
  }
}
terraform {
  source = "${get_path_to_repo_root()}/../modules//ecr/registry"
}

inputs = {
  aws_accounts_enabled_for_pull_through = keys(dependency.account_list.outputs.accounts)
}