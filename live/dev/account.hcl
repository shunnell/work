locals {
  account               = "dev"
  account_id            = "797771596503"
  region                = "us-east-1"
  terragrunter_role_arn = "arn:aws:iam::${local.account_id}:role/terragrunter"
  environment_name      = "dev"

  account_tags = {
    account     = local.account
    Environment = local.environment_name
  }
}
