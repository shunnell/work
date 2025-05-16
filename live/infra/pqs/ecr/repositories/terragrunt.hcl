include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//ecr/tenant_ecr_repositories"
}

locals {
  account_config = read_terragrunt_config("${get_repo_root()}/pqs/account.hcl").locals
}

inputs = {
  tenant_name                   = local.account_config.account
  aws_accounts_with_pull_access = [local.account_config.account_id]
  legacy_ecr_repository_names_to_be_migrated = [
    "pqs/repo-pqs",
    "pqs/repo-pqs/facevacs-runtime"
  ]
}

