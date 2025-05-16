locals {
  account               = "platform_sandbox"
  account_id            = "563391529185"
  region                = "us-east-1"
  terragrunter_role_arn = "arn:aws:iam::${local.account_id}:role/terragrunter"

  account_tags = {
    account = local.account
  }
}
