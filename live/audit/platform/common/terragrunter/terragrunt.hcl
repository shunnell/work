include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "terragrunter" {
  path = "${get_path_to_repo_root()}/_envcommon/bootstrap/terragrunter.hcl"
}
