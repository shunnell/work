locals {
  team_name  = read_terragrunt_config(find_in_parent_folders("team.hcl")).locals.team_tags.team
  account_id = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.account_id
}

terraform {
  source = "${get_repo_root()}/../modules//gitlab/runner_fleet"
}

dependency "cluster" {
  # Using absolute paths in this file to reduce confusion re: "include" and relative paths:
  config_path = "${get_repo_root()}/infra/platform/gitlab/legacy_runners_eks_cluster"
  mock_outputs = {
    cluster_name = ""
  }
}

dependency "secret" {
  config_path = "${get_repo_root()}/infra/platform/gitlab/secret"
  mock_outputs = {
    secret_id = ""
  }
}

dependency "ecr_repositories" {
  config_path = "${get_repo_root()}/infra/${local.team_name}/ecr/repositories"
  mock_outputs = {
    pull_policy = { arn = "" }
    push_policy = { arn = "" }
    view_policy = { arn = "" }
  }
}

inputs = {
  gitlab_mothership_domain = "gitlab.cloud-city"
  chart_version            = "0.78.1"
  cluster_name             = dependency.cluster.outputs.cluster_name
  tenant_name              = local.team_name
  gitlab_secret_id         = dependency.secret.outputs.secret_id
  gitlab_certificate       = file("${get_repo_root()}/_envcommon/platform/gitlab/gitlab-fullchain-cert.crt")
  runner_iam_policy_attachments = [
    dependency.ecr_repositories.outputs.pull_policy.arn,
    dependency.ecr_repositories.outputs.push_policy.arn,
    dependency.ecr_repositories.outputs.view_policy.arn,
    # TODO this is overpermissive and should be split out to allow broad read access to public/pulled-through things
    #   but only allow first-party CodeArtifact resources to be read by the publishing team's runners.
    "arn:aws:iam::aws:policy/AWSCodeArtifactReadOnlyAccess",
  ]
  code_artifact_repos = {
    push = [
      "arn:aws:codeartifact:us-east-1:${local.account_id}:repository/${local.team_name}/*",
      "arn:aws:codeartifact:us-east-1:${local.account_id}:package/${local.team_name}/*",
    ]
    pull         = [] # NB: AWSCodeArtifactReadOnlyAccess should accommodate all pull needs until we control CA policies better.
    pull_through = []
  }
}
