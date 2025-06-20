include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "team_repositories" {
  path = "${get_repo_root()}/_envcommon/platform/ecr/team_repositories.hcl"
}

inputs = {
  # NB: Temporarily disabled to save quota. There's an account-wide limit of 50 pull-through cache rules, and each
  # tenant gets 5-7 rules by default, which doesn't quite fit. While we wait for Nexus/Artifactory to become available,
  # tenants that are not using containers/pull-through regularly have their pull-through caches rules disabled.
  # At the time of this writing (6/12/2025), this tenant is not using their EKS cluster and does not appear to have
  # running CICD pipelines. This can be re-enabled temporarily or permanently for this tenant if the need arises, though
  # that may require playing some "tetris" to fit within the quota (e.g. by disabling specific pull-through upstreams
  # that aren't in use for this or other tenants).
  pull_through_configurations = {}
}