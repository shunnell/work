include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "sso_resource" {
  path = "${get_path_to_repo_root()}/management/platform/sso/utilities/sso_resource.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//iam/sso_permission_set"
}

inputs = {
  permission_set_name = "CAMP_DevSecOps"
  description         = "Allows for DevSecOps access to CAMP-related resources in workload accounts."
  inline_policy       = file("inline_policy.json")
} 