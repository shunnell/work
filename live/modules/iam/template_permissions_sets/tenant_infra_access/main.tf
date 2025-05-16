module "identity_policy_for_codeartifact_repo_access" {
  source       = "../../../codeartifact/identity_policy_for_repo_access"
  repositories = var.allow_code_artifact_repositories
}

module "ecr_view_all_repos_policy" {
  source       = "../../../ecr/access_policy_document"
  repositories = ["*"]
  action       = "view"
}

data "aws_iam_policy_document" "policy" {
  source_policy_documents = concat(
    [
      module.identity_policy_for_codeartifact_repo_access.policy.json,
      module.ecr_view_all_repos_policy.json,
    ],
    [for p in var.iam_attachments : p if !startswith(p, "/")]
  )
  statement {
    sid    = "SecurityScanningBasicAccess"
    effect = "Allow"
    actions = [
      "inspector2:ListCoverage",
      "inspector2:ListFindings",
    ]
    resources = ["*"]
  }
}

# AWS SSO Permission Set resource
resource "aws_ssoadmin_permission_set" "this" {
  name             = "${var.tenant_pretty_name}_${var.tenant_subgroup_name}_Infra"
  description      = "Allows for ${var.tenant_subgroup_name} access to ${var.tenant_pretty_name}-related resources in infra account."
  instance_arn     = var.instance_arn
  session_duration = var.session_duration
  tags             = var.tags
}

# Attach inline policy to the permission set (if provided)
resource "aws_ssoadmin_permission_set_inline_policy" "inline_policy" {
  inline_policy      = data.aws_iam_policy_document.policy.json
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "policy_attachments" {
  for_each           = { for p in var.iam_attachments : p => split("/", p) if startswith(p, "/") }
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  customer_managed_policy_reference {
    name = element(each.value, -1)
    path = "${join("/", slice(each.value, 0, length(each.value) - 1))}/"
  }
}
