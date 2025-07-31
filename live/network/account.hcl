locals {
  account               = "network"
  account_id            = "975050075035"
  region                = "us-east-1"
  terragrunter_role_arn = "arn:aws:iam::${local.account_id}:role/terragrunter"
  bespin_cidr_block     = "172.16.0.0/12"
  environment_name      = "infrastructure"

  account_tags = {
    account     = local.account
    Environment = local.environment_name
  }
}
