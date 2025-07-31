## AKA : FPT847 Dept of State Consular Affairs

locals {
  account                     = "management"
  account_id                  = "590183957203"
  region                      = "us-east-1"
  terragrunter_role_arn       = "arn:aws:iam::${local.account_id}:role/terragrunter"
  bespin_organization_root_id = "o-9cdv0jbn8r"
  organization_root_id        = "r-ikpg"
  environment_name            = "infrastructure"

  account_tags = {
    account     = local.account
    Environment = local.environment_name
  }
}
