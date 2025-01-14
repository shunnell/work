# Attach inline policy to the permission set (if provided)
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  count = var.inline_policy != null ? 1 : 0

  inline_policy      = var.inline_policy
  instance_arn       = var.instance_arn
  permission_set_arn = var.permission_set_arn
}
