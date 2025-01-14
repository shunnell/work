output "inline_policy_arn" {
  description = "The ARN of the Inline Policy"
  value       = aws_ssoadmin_permission_set_inline_policy.this.arn
}
