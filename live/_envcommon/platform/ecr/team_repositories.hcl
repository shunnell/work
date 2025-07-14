terraform {
  source = "${get_repo_root()}/../modules//ecr/tenant_ecr_repositories"
}

dependency "registry" {
  config_path = "${get_repo_root()}/infra/platform/ecr/registry"
  mock_outputs = {
    pull_through_configurations = {}
  }
}

locals {
  team_name = read_terragrunt_config(find_in_parent_folders("team.hcl")).locals.team_tags.team
  # TODO this is an ugly hack; team names and account folder names should correspond. Until we fix that (which is a
  #   big `git mv` and a bunch of reference updates), we patch it up for the ones that aren't congruent here:
  account_folder_overrides = {
    "data-platform" = "data"
    "platform"      = "infra"
  }
  # Disable some rarely-used pull-through upstreams for most tenants. This is done to save precious slots in the
  # acount-wide limit of 50 total pull-through-cache rules (each tenant needs 5-7). Some tenants (who look inactive or
  # do not seem to be using images heavily in CICD or EKS) also have their pull-through caches disabled entirely where
  # this file is included.
  rarely_used_pull_through_upstreams = ["k8s", "quay"]
  account_folder_name                = lookup(local.account_folder_overrides, local.team_name, local.team_name)
  account_config                     = read_terragrunt_config("${get_repo_root()}/${local.account_folder_name}/account.hcl").locals
  infra_config                       = read_terragrunt_config("${get_repo_root()}/infra/account.hcl").locals
}

inputs = {
  tenant_name = local.team_name
  aws_accounts_with_pull_access = [
    # Allow the tenant's sandbox account to pull images:
    local.account_config.account_id,
    # Infra can always pull images in order to allow CICD image testing/utilization to work:
    local.infra_config.account_id,
  ]
  pull_through_configurations = {
    for k, v in dependency.registry.outputs.pull_through_configurations :
    k => v if !contains(local.rarely_used_pull_through_upstreams, k)
  }
}

