locals {
  account               = "ocam"
  account_id            = "699475935240"
  region                = "us-east-1"
  terragrunter_role_arn = "arn:aws:iam::${local.account_id}:role/terragrunter"
  environment_name      = "sandbox"

  account_tags = {
    account     = local.account
    Environment = local.environment_name
  }
}
