# AWS SSO Permission Set resource
resource "aws_ssoadmin_permission_set" "this" {
  name             = var.permission_set_name
  description      = var.description
  instance_arn     = var.instance_arn
  session_duration = var.session_duration

  tags = var.tags
}

# Attach managed policies to the permission set
resource "aws_ssoadmin_managed_policy_attachment" "managed_policy" {
  for_each = toset(var.managed_policy_arns)

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  managed_policy_arn = each.value
}

# Attach inline policy to the permission set (if provided)
resource "aws_ssoadmin_permission_set_inline_policy" "inline_policy" {
  count = var.inline_policy != null ? 1 : 0

  inline_policy      = var.inline_policy
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}
