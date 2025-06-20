data "aws_caller_identity" "ecr_account" {}

data "aws_region" "ecr_region" {}


locals {
  common = [
    "ecr:GetAuthorizationToken",
    "ecr:DescribeRepositories",
    "ecr:DescribeRegistry",
    "ecr:GetRegistryScanningConfiguration",
    "ecr:GetImageCopyStatus",
    "ecr:ValidatePullThroughCacheRule",
  ]
  view = [
    "ecr:DescribeImages",
    "ecr:ListImages",
    "ecr:ListTagsForResource",
    "ecr:DescribeImageScanFindings",
  ]
  pull = [
    "ecr:BatchCheckLayerAvailability",
    "ecr:BatchGetImage",
    "ecr:GetDownloadUrlForLayer",
    # Pull implies pull-through:
    "ecr:BatchImportUpstreamImage"
  ]
  delete = [
    "ecr:BatchDeleteImage",
    "ecr:DeleteRepository",
    "ecr:TagResource",
  ]
  push = [
    "ecr:CompleteLayerUpload",
    "ecr:InitiateLayerUpload",
    "ecr:PutImage",
    "ecr:CreateRepository",
    "ecr:UploadLayerPart",
    "ecr:TagResource",
  ]
  repositories = toset([
    for r in var.repositories :
    "arn:aws:ecr:${data.aws_region.ecr_region.region}:${data.aws_caller_identity.ecr_account.account_id}:repository/${r}"
  ])
}
