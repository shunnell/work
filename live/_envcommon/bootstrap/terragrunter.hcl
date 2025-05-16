locals {
  infra = read_terragrunt_config("${get_repo_root()}/infra/account.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//common/terragrunter/"
}

inputs = {
  iac_account_id = local.infra.locals.account_id
}
