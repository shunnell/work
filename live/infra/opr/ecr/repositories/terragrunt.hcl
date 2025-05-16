include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//ecr/tenant_ecr_repositories"
}

locals {
  account_config = read_terragrunt_config("${get_repo_root()}/opr/account.hcl").locals
}

inputs = {
  tenant_name                   = local.account_config.account
  aws_accounts_with_pull_access = [local.account_config.account_id]
  legacy_ecr_repository_names_to_be_migrated = [
    "dos-ca-opr-v3-application-repo",
    "dos-ca-opr-v3-helm-chart",
    "dos-ca-opr-v3-job-runner-repo",
    "dos-ca-opr-v3-mock-apis-repo",
    "dos-ca-opr-v3-setup-ssl-certs-repo",
    "opr/application/opr-app-python",
  ]
}
