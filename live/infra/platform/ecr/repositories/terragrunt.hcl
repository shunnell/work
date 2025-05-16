include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//ecr/tenant_ecr_repositories"
}

locals {
  account_config = read_terragrunt_config("${get_repo_root()}/infra/account.hcl").locals
}

inputs = {
  tenant_name = local.account_config.account
  # TODO we may expand this to allow first-party platform images to be pulled by other accounts at some point:
  aws_accounts_with_pull_access = []
}
