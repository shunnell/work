output "arn" {
  description = "The ARN of the SSO Instance"
  value       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

output "identity_store_id" {
  description = "The Identity Store associated with the sso isntance"
  value       = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}