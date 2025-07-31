terraform {
  source = "${get_path_to_repo_root()}/../modules//iam/template_permissions_sets/tenant_infra_access"
}

locals {
  team = read_terragrunt_config(find_in_parent_folders("team.hcl")).locals
}

dependency "ecr_repositories" {
  config_path = "${get_repo_root()}/infra/${local.team.team}/ecr/repositories"
  mock_outputs = {
    pull_policy   = { arn = "arn:aws:iam:region:1234:policy/foo" }
    push_policy   = { arn = "arn:aws:iam:region:1234:policy/bar" }
    view_policy   = { arn = "arn:aws:iam:region:1234:policy/baz" }
    delete_policy = { arn = "arn:aws:iam:region:1234:policy/baz" }
  }
}

inputs = {
  tenant_pretty_name = local.team.pretty_name
  iam_attachments = [
    "/${split(":policy/", dependency.ecr_repositories.outputs.pull_policy.arn)[1]}",
    "/${split(":policy/", dependency.ecr_repositories.outputs.view_policy.arn)[1]}",
    # Human users can delete their own ECR images, for now. That may be restricted at some point in the future, but
    # nobody has asked for such a restriction yet:
    "/${split(":policy/", dependency.ecr_repositories.outputs.delete_policy.arn)[1]}",
    # TODO: If we ever chose to restrict human users' ability to push to ECR (requiring that pushes be performed in CI),
    #    then this line can be removed:
    "/${split(":policy/", dependency.ecr_repositories.outputs.push_policy.arn)[1]}",
  ]
  allow_code_artifact_repositories = {
    push = [
      # TODO consider whether we want human users to be able to push to these or not:
      "arn:aws:codeartifact:*:*:repository/${local.team.team}/*",
      "arn:aws:codeartifact:*:*:package/${local.team.team}/*",
    ]
    pull = [
      "arn:aws:codeartifact:*:*:repository/${local.team.team}/*",
      "arn:aws:codeartifact:*:*:package/${local.team.team}/*",
    ]
    pull_through = []
  }
}