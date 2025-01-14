resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.role_json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arns[count.index]
}
