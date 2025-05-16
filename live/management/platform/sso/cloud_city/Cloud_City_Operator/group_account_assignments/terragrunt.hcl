include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "all_accounts_group_assignment" {
  path = "${get_path_to_repo_root()}/management/platform/sso/utilities/all_accounts_group_assignment.hcl"
}

inputs = {
  group_display_name = "Cloud City Platform Operator Users"
}
