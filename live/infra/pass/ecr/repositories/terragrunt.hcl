include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "team_repositories" {
  path = "${get_repo_root()}/_envcommon/platform/ecr/team_repositories.hcl"
}
