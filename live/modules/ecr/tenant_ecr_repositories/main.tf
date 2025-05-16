resource "aws_ecr_repository" "legacy_repositories" {
  for_each = var.legacy_ecr_repository_names_to_be_migrated
  # NB: deletion requires repos to be *created* with the force-delete flag:
  # https://github.com/hashicorp/terraform-provider-aws/issues/33523
  force_delete         = true
  name                 = each.key
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}

module "identity_policies" {
  for_each    = local.action_types
  source      = "../../iam/policy"
  policy_name = "${var.tenant_name}-ECR${title(each.key)}"
  policy_path = "/CloudCity/${var.tenant_name}/"
  policy_json = module.identity_policy_documents[each.key].json
}

resource "aws_ecr_repository_policy" "legacy_repository_policies" {
  for_each   = var.legacy_ecr_repository_names_to_be_migrated
  repository = each.key
  policy     = local.per_repo_pull_policy
}

# NB: This creation template *looks* unused, but code in the "bespinctl aws ecr" family reads from it when determining
# what policies propagate onto existent repos. This is done because creation templates only auto-apply when AWS itself
# creates a repo (via replication or pull-through), but not when users create a repo by pushing to a prefix they have
# permission to create new repos in. While the basically-undocumented "ROOT" creation template could be used to
# automatically create repos with appropriate per-tenant permissions (which mostly boil down to what other AWS accounts
# a repo should be pullable by), that's both sketchy/undocumented, and requires creating a complex composite ROOT
# creation template that knows about all tenants' desired repo policies, leading to some pretty ugly terraform code.
# Instead, we create templates for pullthrough sources and also create nominally-unused templates like this one.
# Procedural code running in a periodic job will discover these templates and "retcon" their content onto repositories
# which match a given template's prefix.
resource "aws_ecr_repository_creation_template" "template" {
  description          = "Template for ${var.tenant_name}'s first-party published images, to be shared for pull with accounts: ${join(",", var.aws_accounts_with_pull_access)}"
  applied_for          = ["REPLICATION"] # Even though we aren't replicating at the moment, this needs a value, and calling it pull-through would be misleading.
  prefix               = "cloud-city/${var.tenant_name}"
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  repository_policy = local.per_repo_pull_policy
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
