include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "sso_resource" {
  path = "${get_path_to_repo_root()}/management/platform/sso/utilities/sso_resource.hcl"
}

include "infra_permission_set" {
  path = "${get_path_to_repo_root()}/management/platform/sso/utilities/tenant_infra_permission_set.hcl"
}

inputs = {
  tenant_subgroup_name = "Dev"
}