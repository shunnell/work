include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  management_account = read_terragrunt_config("${get_repo_root()}/management/account.hcl").locals
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//ecr/registry"
}

inputs = {
  pull_organizational_units = [
    # Sandbox OU
    "${local.management_account.bespin_organization_root_id}/${local.management_account.organization_root_id}/ou-ikpg-pgv9aes3",
    # Infra OU
    "${local.management_account.bespin_organization_root_id}/${local.management_account.organization_root_id}/ou-ikpg-gcssee37",
    # Production OU
    "${local.management_account.bespin_organization_root_id}/${local.management_account.organization_root_id}/ou-ikpg-wzv07v0d"
  ]
  pull_through_organizational_units = [
    # Sandbox OU
    "${local.management_account.bespin_organization_root_id}/${local.management_account.organization_root_id}/ou-ikpg-pgv9aes3s",
    # Infra OU
    "${local.management_account.bespin_organization_root_id}/${local.management_account.organization_root_id}/ou-ikpg-gcssee37",
  ]
}