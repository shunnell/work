locals {
  account               = "audit"
  account_id            = "637423310032"
  region                = "us-east-1"
  terragrunter_role_arn = "arn:aws:iam::${local.account_id}:role/terragrunter"
  environment_name      = "infrastructure"

  account_tags = {
    account     = local.account
    Environment = local.environment_name
  }
}
