output "role_id" {
  description = "The id of the IAM role"
  value       = aws_iam_role.this.id
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.this.arn
}
