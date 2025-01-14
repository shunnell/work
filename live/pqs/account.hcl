locals {
  account               = "pqs"
  account_id            = "034362069573"
  region                = "us-east-1"
  terragrunter_role_arn = "arn:aws:iam::${local.account_id}:role/terragrunter"

  account_tags = {
    account = local.account
  }
}
