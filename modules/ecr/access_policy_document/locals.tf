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
    "ecr:GetLifecyclePolicy",
    "ecr:GetLifecyclePolicyPreview",
    "ecr:GetRepositoryPolicy",
    "ecr:StartLifecyclePolicyPreview",
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
    "ecr:DeleteLifecyclePolicy",
    "ecr:DeleteRepositoryPolicy",
  ]
  push = [
    "ecr:CompleteLayerUpload",
    "ecr:InitiateLayerUpload",
    "ecr:PutImage",
    "ecr:CreateRepository",
    "ecr:UploadLayerPart",
    "ecr:TagResource",
    # Anyone who can push can also edit lifecycle policies to specify custom retention behavior. Some tenants want to,
    # for example, reduce the retention defaults from 64 images to just one, which they are free to do.
    "ecr:DeleteLifecyclePolicy",
    "ecr:PutLifecyclePolicy",

  ]
  repositories = toset([
    for r in var.repositories :
    "arn:aws:ecr:${data.aws_region.ecr_region.region}:${data.aws_caller_identity.ecr_account.account_id}:repository/${r}"
  ])
}
