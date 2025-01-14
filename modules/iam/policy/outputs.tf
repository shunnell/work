output "policy_id" {
  description = "The id of the IAM policy"
  value       = aws_iam_policy.this.id
}

output "policy_arn" {
  description = "The ARN of the IAM policy"
  value       = aws_iam_policy.this.arn
}
