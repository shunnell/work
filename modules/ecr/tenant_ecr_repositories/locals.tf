locals {
  action_types = toset(["pull", "push", "view", "delete"])
  policy_outputs = { for t in local.action_types : t => {
    arn  = module.identity_policies[t].policy_arn
    path = module.identity_policies[t].policy_path,
    name = module.identity_policies[t].policy_name,
  } }
  pull_through_prefix_to_uri = {
    # NB: if adding pull-through sources here, prefer the shortest possible descriptive name as a key; see comments in
    # the repository_creation_template resource in pull_through.tf for more information.
    "docker"     = "registry-1.docker.io"
    "ecr-public" = "public.ecr.aws"
    "github"     = "ghcr.io"
    "gitlab"     = "registry.gitlab.com"
    "k8s"        = "registry.k8s.io"
    "quay"       = "quay.io"
  }
  # TODO: hack to support platform-team legacy images, which have a huge list of legacy prefixes from the old pullthrough rules.
  #   Passing the whole list verbatim hits a policy length limit that can't be raised by AWS, so we do a very crude
  #   "compression" pass here.
  legacy_repo_iam_prefixes = var.tenant_name != "platform" ? var.legacy_ecr_repository_names_to_be_migrated : concat(
    [for prefix in keys(local.pull_through_prefix_to_uri) : "${prefix}/*"],
    [for repo in var.legacy_ecr_repository_names_to_be_migrated : repo if !anytrue([for prefix in keys(local.pull_through_prefix_to_uri) : startswith(repo, prefix)])]
  )
  template_description = "Repositories for Cloud City tenant '${var.tenant_name}'; shared for pull with ${length(var.aws_accounts_with_pull_access)} accounts: ${join(",", var.aws_accounts_with_pull_access)}"
}
