include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "team_repositories" {
  path = "${get_repo_root()}/_envcommon/platform/ecr/team_repositories.hcl"
}

inputs = {
  legacy_ecr_repository_names_to_be_migrated = [
    "pqs/repo-pqs",
    "pqs/repo-pqs/facevacs-runtime"
  ]
}

