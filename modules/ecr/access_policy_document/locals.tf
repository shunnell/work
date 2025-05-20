data "aws_caller_identity" "ecr_account" {}

data "aws_region" "ecr_region" {}


locals {
  common = [
    "ecr:GetAuthorizationToken",
    "ecr:DescribeRepositories",
    "ecr:DescribeRegistry",
    "ecr:GetRegistryScanningConfiguration",
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
  ]
  push = [
    "ecr:CompleteLayerUpload",
    "ecr:InitiateLayerUpload",
    "ecr:PutImage",
    "ecr:CreateRepository",
    "ecr:UploadLayerPart",
    # TODO push permissions temporarily also imply delete permissions so that tenants can delete mistakenly-created
    #   artifacts. That may at some point be relitigated/removed (e.g. for preservation of old image versions for
    #   audit/forensic purposes). At that point, the below permission grants should be moved or removed:
    "ecr:BatchDeleteImage",
    "ecr:DeleteRepository",
  ]
  pull_through = [
    "ecr:BatchImportUpstreamImage",
    "ecr:CreateRepository",
    "ecr:GetImageCopyStatus",
  ]
  repositories = [
    for r in var.repositories :
    "arn:aws:ecr:${data.aws_region.ecr_region.name}:${data.aws_caller_identity.ecr_account.account_id}:repository/${r}"
  ]
}
