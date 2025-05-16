resource "aws_iam_policy" "this" {
  name        = var.policy_name
  name_prefix = var.name_prefix
  path        = var.policy_path
  policy      = var.policy_json
  description = var.policy_description
  tags        = var.tags
}
