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
  permission_set_name = "OPR_Observer"
  description         = "Allows for observation of OPR-specific resources in shared workload accounts."
  managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
} 