include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "."
}

inputs = {
  # Reading the org ID from the management account rather than our own account.hcl, since this invocation deals with
  # cross-account data management within the management account's organization.
  aws_organization_id = read_terragrunt_config("${get_path_to_repo_root()}/management/account.hcl").locals.bespin_organization_root_id
}
