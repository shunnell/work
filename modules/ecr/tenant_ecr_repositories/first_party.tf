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

resource "aws_ecr_repository_policy" "legacy_repository_policies" {
  for_each   = var.legacy_ecr_repository_names_to_be_migrated
  repository = each.key
  policy     = data.aws_iam_policy_document.repo_policy.json
  depends_on = [aws_ecr_repository.legacy_repositories]
}
