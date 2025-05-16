# Do NOT include this file anywhere in the "live/" repo. This file is exclusively for use when running the initial
# apply to create the 'terragrunter' user in a brand new AWS account. It should not be used (even for managing
# terragrunter) after that point. It differs from the standard root.hcl in several ways:
# - It does not store state anywhere (local state).
# - It runs as the invoking IAM user (should be an admin-permissioned SSO user in the target account), not "terragrunter".
# - It fails unless it is involed for an account specified in an environment variable.

locals {
  region     = "us-east-1"
  account_id = get_env("DOS_CLOUD_CITY_ACCOUNT_ID")
}

generate "provider" {
  path      = "bootstrap_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.region}"
      allowed_account_ids = ["${local.account_id}"]
    }
  EOF
}

include "terragrunter" {
  path = "./terragrunter.hcl"
}
