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
  permission_set_name = "Sandbox_Dev"
  description         = "Allows for experimentation and iteration without allowing changes to IAM, Networking, or Security, controls"
  inline_policy       = file("inline_policy.json")
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorFullAccess"
  ]
}