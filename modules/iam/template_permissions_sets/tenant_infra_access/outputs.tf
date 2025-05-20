output "permission_set_arn" {
  description = "The ARN of the created permission set."
  value       = aws_ssoadmin_permission_set.this.arn
}