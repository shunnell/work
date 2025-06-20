data "aws_iam_policy_document" "accountwide_pull_through_policy" {
  statement {
    sid = "OtherAccountsPullThrough"
    actions = [
      # NB: Even though these permissions are added account-wide, the necessary bits to initiate a pullthrough and to
      # read a pulled through image are provided by the `tenant_ecr_repositories` module. The pull-through control is
      # installed here to simplify other image permission management code, but the actual permission "gates" are
      # elsewhere.
      "ecr:BatchImportUpstreamImage",
      "ecr:GetImageCopyStatus",
      "ecr:GetDownloadUrlForLayer",
      # TODO the AWS docs mention CreateRepository is needed, but it doesn't seem to be necessary. Tenants are able
      #   to create pulled-through images in their namespace regardless. Adding it here would technically allow over-
      #   -broad access for everyone to create empty repos, so it's omitted for now, but how things work without it is
      #   a mystery that should be solved.
    ]
    principals {
      identifiers = [for account in var.aws_accounts_enabled_for_pull_through : "arn:aws:iam::${account}:root"]
      type        = "AWS"
    }
    # Per-tenant pull-through paths:
    resources = [for prefix in keys(local.pull_through_prefix_to_secret_name) : "${local.repo_stem}/*/${prefix}/*"]
  }
}

resource "aws_ecr_registry_policy" "accountwide_registry_policy" {
  policy = data.aws_iam_policy_document.accountwide_pull_through_policy.json
}

module "pull_through_secrets" {
  source                         = "../../secret"
  for_each                       = toset([for v in values(local.pull_through_prefix_to_secret_name) : v if v != null])
  name                           = "ecr-pullthroughcache/${each.key}"
  description                    = "${each.key} secret for ECR pull-through cache"
  value                          = "<externally/manually set>"
  ignore_changes_to_secret_value = true
  tags                           = var.tags
}
