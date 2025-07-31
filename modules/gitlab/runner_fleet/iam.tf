locals {
  default_code_artifact_repos = {
    push = []
    pull = [
      "arn:aws:codeartifact:us-east-1:381492150796:repository/platform-infra-repo/maven-central-store",
      "arn:aws:codeartifact:us-east-1:381492150796:repository/platform-infra-repo/platform-infra-repository",
      "arn:aws:codeartifact:us-east-1:381492150796:repository/platform-infra-repo/maven-central-store",
      "arn:aws:codeartifact:us-east-1:381492150796:repository/platform-infra-repo/pypi-store",
      "arn:aws:codeartifact:us-east-1:381492150796:repository/platform-infra-repo/npm-store",
    ]
    pull_through = []
  }

  # Merge defaults with the variables
  merged = {
    code_artifact_repos = { for category, arn_set in var.code_artifact_repos : category => setunion(local.default_code_artifact_repos[category], arn_set) }
  }
}

module "codeartifact_identity_policy" {
  source       = "../../codeartifact/identity_policy_for_repo_access"
  repositories = local.merged.code_artifact_repos
}

data "aws_iam_policy_document" "policy_document" {
  source_policy_documents = [module.codeartifact_identity_policy.policy.json]
  dynamic "statement" {
    for_each = length(var.deployer_roles) > 0 ? [1] : []
    content {
      sid    = "AssumeDeployerRoles"
      effect = "Allow"
      actions = [
        "sts:AssumeRole",
        "sts:AssumeRoleWithWebIdentity"
      ]
      resources = var.deployer_roles
    }
  }
  statement {
    sid    = "AllowDescribePipeAndGetRole"
    effect = "Allow"
    actions = [
      "pipes:DescribePipe",
      "iam:GetRole",
    ]
    resources = ["*"]
  }
}

module "runner_iam_policy" {
  source      = "../../iam/policy"
  policy_name = local.runner_fleet_name
  policy_json = data.aws_iam_policy_document.policy_document.json
  tags        = local.tags
}

module "runner_iam_role" {
  source = "../../eks/service_account"

  name                        = local.runner_irsa_name
  use_name_as_iam_role_prefix = false
  namespace                   = kubernetes_namespace.fleet_namespace.metadata[0].name
  cluster_name                = var.cluster_name
  # This is a bit silly. We're close to the edge of pure Terraform's ability to combine resources (the point at which
  # we'd consider reaching for Terragrunt separation) but not quite over it: the iam policy module produces a
  # predictable ARN, but if we depend on that output, Terraform will give up on the determinism of this value, so it
  # can't be used to decare resource vectors. Why is it a set and not a list? Because 3 layers of module indirection
  # below this (runner_fleet -> service_account -> IRSA third party code -> iam resources) third-party code insists on
  # taking an argument as a dict. And this is why we always remember, kids: hash-based variables (sets, maps) should
  # only be used when really necessary to express important concepts, not just for nice-to-have reasons like deduping
  # or uniqueness assertions. If you need those things, accept a vector (list, tuple) and validate in conditions
  # instead, otherwise you have to go through the 90min it took me to figure this out in the middle of the night during
  # a maintenance event. ~ZB, 0425.
  depends_on      = [module.runner_iam_policy.policy_arn]
  iam_policy_arns = setunion(["arn:aws:iam::381492150796:policy/${local.runner_fleet_name}"], var.runner_iam_policy_attachments)

  tags = local.tags
}
