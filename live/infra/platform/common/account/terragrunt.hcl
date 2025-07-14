include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "baseline" {
  path = "${get_repo_root()}/_envcommon/platform/common/account/baseline.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//common/account/"
}
