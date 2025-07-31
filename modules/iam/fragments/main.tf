data "aws_iam_policy_document" "tenant_development_permissions" {
  source_policy_documents = [
    data.aws_iam_policy_document.general_services_permissions.minified_json,
    data.aws_iam_policy_document.tenant_ec2_permissions.minified_json,
    data.aws_iam_policy_document.tenant_eks_permissions.minified_json,
    data.aws_iam_policy_document.tenant_iam_permissions.minified_json,
  ]
}

data "aws_iam_policy_document" "no_permissions" {
  statement {
    actions   = ["*"]
    effect    = "Deny"
    resources = ["*"]
  }
}