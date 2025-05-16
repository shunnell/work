output "permission_set_arn" {
  description = "The ARN of the Permission Set"
  value       = aws_ssoadmin_permission_set.this.arn
}

output "permission_set_id" {
  description = "The ID of the Permission Set"
  value       = aws_ssoadmin_permission_set.this.id
}
