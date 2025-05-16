output "policy_name" {
  description = "The name of the IAM policy"
  value       = aws_iam_policy.this.name
}

output "policy_path" {
  description = "The path of the IAM policy"
  value       = aws_iam_policy.this.path
}

output "policy_arn" {
  description = "The ARN of the IAM policy"
  value       = aws_iam_policy.this.arn
}
