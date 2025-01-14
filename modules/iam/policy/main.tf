resource "aws_iam_policy" "this" {
  name   = var.policy_name
  path   = var.policy_path
  policy = var.policy_json
  tags   = var.tags
}
