/*
Occasionally, Platform team needs to test changes in how runners are configured or deployed via IaC. Doing that by
changing existing runner fleets can be disruptive, and experimenting on the platform team's main runner fleet is no
exception (one platform engineer's runner provisioning changes shouldn't risk disruption of all other platform team
engineers' work).

This fleet exists as a permanent (scaled way down in order to not consume too many resources) place for experimentation
on runners to happen, without requiring experimenters to go through the hassle of allocating runners in the GitLab
admin console and storing tokens in secrets manager each time they want to try something out.

Its its workers will only run jobs with the "runner-testing" tag.
*/

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
  runner_fleet_name = "platform-team-runner-testing"
  concurrency_pods  = 1 # Keep it scaled way down to not take up too much space.
}
