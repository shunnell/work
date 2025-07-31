data "aws_iam_policy_document" "tenant_eks_restrictions" {
  statement {
    sid    = "DenyAddonModification"
    effect = "Deny"
    actions = [
      "eks:CreateAddon",
      "eks:UpdateAddon",
      "eks:DeleteAddon",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "tenant_eks_permissions" {
  statement {
    sid    = "EKS"
    effect = "Allow"
    actions = [
      "eks:AccessKubernetesApi",
      "eks:Describe*",
      "eks:List*",
    ]
    resources = ["*"]
  }
}