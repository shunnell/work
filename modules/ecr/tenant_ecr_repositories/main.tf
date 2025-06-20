module "resource_policies" {
  for_each   = toset(["view", "pull"])
  source     = "../access_policy_document"
  action     = each.key
  principals = [for account in var.aws_accounts_with_pull_access : "arn:aws:iam::${account}:root"]
}

module "identity_policy_documents" {
  for_each = local.action_types
  source   = "../access_policy_document"
  action   = each.key
  repositories = setunion(
    local.legacy_repo_iam_prefixes,
    ["${var.tenant_name}/internal/*"],
    # Don't let people push to pull-through targets, but let them delete/pull/view/etc.:
    [for prefix in keys(local.pull_through_prefix_to_uri) : "${var.tenant_name}/${prefix}/*" if each.key != "push"],
  )
  depends_on = [aws_ecr_repository_creation_template.template]
}

module "identity_policies" {
  for_each    = local.action_types
  source      = "../../iam/policy"
  policy_name = "${var.tenant_name}-ECR${title(each.key)}"
  policy_path = "/CloudCity/${var.tenant_name}/"
  policy_json = module.identity_policy_documents[each.key].json
  tags        = var.tags
}

data "aws_iam_policy_document" "repo_policy" {
  source_policy_documents = values(module.resource_policies)[*].json
}

# NB: This creation template is used for two things (rather than separate creation templates per-image-type; an
# account-wide hard limit of 50 creation templates prevents this):
# 1. Setting permissions/config on new images created via pull-through.
# 2. Propagating permissions onto tenant-created repositories. Code in the "bespinctl aws ecr" family reads from it
# when determining what policies propagate onto existent repos. This is done because creation templates only auto-apply
# when AWS itself creates a repo (via replication or pull-through), but not when users create a repo by pushing to a
# prefix they have permission to create new repos in.
# While the basically-undocumented "ROOT" creation template could be used to
# automatically create repos with appropriate per-tenant permissions (which mostly boil down to what other AWS accounts
# a repo should be pullable by), that's both sketchy/undocumented, and requires creating a complex composite ROOT
# creation template that knows about all tenants' desired repo policies, leading to some pretty ugly terraform code.
# Instead, we create one template for all of a tenant's images, pulled through or not, here.
# Procedural code running in a periodic job will discover these templates and "retcon" their content onto repositories
# which match a given template's prefix.
resource "aws_ecr_repository_creation_template" "template" {
  description = length(local.template_description) > 255 ? "${substr(local.template_description, 0, 250)}..." : local.template_description
  applied_for = ["PULL_THROUGH_CACHE"]
  # NB: while it would be ideal to use a longer path, e.g. '<tenant>/pullthrough/<key>' or 'cloud-city/<tenant>/...',
  # AWS imposes a 30chr max length limit on pullthrough prefixes. Given that space is precious, we use the shortest
  # possible identifiers which correspond to tenant names and upstreams.
  prefix               = var.tenant_name
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  repository_policy = data.aws_iam_policy_document.repo_policy.json
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
  resource_tags = var.tags
}