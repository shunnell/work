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
  # maximum timeout = 24h
  builder_volume = "100Gi"
  builder_memory = "3Gi"
  # Make sure the IAM role used inside the cluster matches the name of the role that the infra/gitops IAM code allows
  # terragrunter to assume. We're not having the terragrunter IAM IaC code depend on this module because the IAM for
  # terragrunter is "bootstrap phase" code that we want to be able to run before anything else (including EKS/GitLab) is
  # up. Doing otherwise would create a "loop" if we needed to come back from a total wipe: terragrunter IAM would
  # require GitLab runners which would require EKS which would require terragrunter to exist with permissions to create
  # all those things. Instead, we set up "one direction" of that dependency using the service account variable as a
  # means of keeping them in sync.
  # If other teams need to set up special assumption policies for their runners' role, they should do that normally
  # by setting a dependency on the instantion of "runner_fleet" for that team and using that module's outputs.
  # ../../common/terragrunter
}
