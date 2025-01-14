## AKA : FPT847 Dept of State Consular Affairs

locals {
  account               = "management"
  account_id            = "590183957203"
  region                = "us-east-1"
  terragrunter_role_arn = "arn:aws:iam::${local.account_id}:role/terragrunter"

  account_tags = {
    account = local.account
  }
}
