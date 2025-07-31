locals {
  account               = "prod"
  account_id            = "390402578610"
  region                = "us-east-1"
  terragrunter_role_arn = "arn:aws:iam::${local.account_id}:role/terragrunter"
  environment_name      = "production"

  account_tags = {
    account     = local.account
    Environment = local.environment_name
  }
}
