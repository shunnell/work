locals {
  account               = "subordinateca"
  account_id            = "430118816674"
  region                = "us-east-1"
  terragrunter_role_arn = "arn:aws:iam::${local.account_id}:role/terragrunter"
  environment_name      = "infrastructure"

  account_tags = {
    account     = local.account
    Environment = local.environment_name
  }
}
