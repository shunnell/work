data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "cluster" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

locals {
  oidc_arn                   = data.aws_iam_openid_connect_provider.cluster.arn
  kms_secret_arns            = [for arn in var.secret_arns : arn if startswith(arn, "arn:aws:kms")]
  secretsmanager_secret_arns = [for arn in var.secret_arns : arn if startswith(arn, "arn:aws:secretsmanager")]
}