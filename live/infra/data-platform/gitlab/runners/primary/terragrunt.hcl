include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "k8s" {
  path = "${get_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

include "runner_fleet" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/gitlab/team_runner_fleet.hcl"
}

inputs = {
  # TODO this is temporary, hardcoded, and will need to be removed and replaced with an entirely different system for
  #   managing deployer roles in the very near future. This is managed temporarily to remove some high-severity security
  #   findings related to IAM user principals.
  deployer_roles = [
    "arn:aws:iam::976193220746:role/sandbox-data-platform-iac-role"
  ]
}
