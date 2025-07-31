include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Load common variables
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

terraform {
  source = "."
}

inputs = {
  organization_root_id = local.account.locals.organization_root_id
}