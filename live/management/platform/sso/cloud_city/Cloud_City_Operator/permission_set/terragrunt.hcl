include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "sso_resource" {
  path = "${get_repo_root()}/management/platform/sso/utilities/sso_resource.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//iam/sso_permission_set"
}

inputs = {
  permission_set_name = "Cloud_City_Operator_Group"
  description         = "Cloud City Operator Group Permission Set"
  # TODO: the "Operator" role isn't well understood. It should potentially have more than ReadOnlyAccess, depending on
  #   future needs for that role. If issues with that role needing to modify (rather than just read) things come up,
  #   this permission set should be updated; ReadOnlyAccess is here as a placeholder/default more than anything.
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}
