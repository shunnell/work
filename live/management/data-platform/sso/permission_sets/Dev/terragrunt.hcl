include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "sso_resource" {
  path = "${get_path_to_repo_root()}/management/platform/sso/utilities/sso_resource.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/iam/sso_permission_set"
}

inputs = {
  permission_set_name = "Data-Platform_Dev"
  description         = "Allows for developer access to Data-Platform-related resources in workload accounts."
  inline_policy       = file("inline_policy.json")
}