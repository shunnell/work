module "view_policy_document" {
  source = "../access_policy_document"
  action = "view"
  # All principals in the local AWS account can view ECR repos/images/metadata:
  principals = ["*"]
}

module "pull_policy_document" {
  source     = "../access_policy_document"
  action     = "pull"
  principals = length(var.pull_organizational_units) > 0 ? ["*"] : []
  conditions = [{
    test     = "ForAnyValue:StringEquals"
    variable = "aws:PrincipalOrgPaths"
    values   = [for ou in var.pull_organizational_units : "${trimsuffix(ou, "/")}/"]
  }]
}

module "pull_through_policy_document" {
  source     = "../access_policy_document"
  action     = "pull_through"
  principals = length(var.pull_through_organizational_units) > 0 ? ["*"] : []
  conditions = [{
    test     = "ForAnyValue:StringEquals"
    variable = "aws:PrincipalOrgPaths"
    values   = [for ou in var.pull_through_organizational_units : "${trimsuffix(ou, "/")}/"]
  }]
}

data "aws_iam_policy_document" "policy" {
  source_policy_documents = [
    module.view_policy_document.json,
    module.pull_policy_document.json,
    module.pull_through_policy_document.json,
  ]
}

# Use this to ensure we never have to import newly created repositories in order for them to follow the model.
resource "aws_ecr_repository_creation_template" "template" {
  for_each             = local.pull_through_upstreams
  description          = "${each.key}: This template is paired with pull-through-cache rules to ensure appropriate access policies for images from public ${each.key} repos"
  applied_for          = ["PULL_THROUGH_CACHE"]
  prefix               = each.value.ecr_repository_prefix
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  repository_policy = data.aws_iam_policy_document.policy.json
  lifecycle_policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep only 64 untagged images",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "imageCountMoreThan",
          "countNumber" : 64
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}

# Build all the cache rules
resource "aws_ecr_pull_through_cache_rule" "rule" {
  for_each              = local.pull_through_upstreams
  ecr_repository_prefix = each.value.ecr_repository_prefix
  upstream_registry_url = each.value.upstream_registry_url
  credential_arn        = each.value.credential_arn
}
