output "secret_id" {
  description = "Secret ID."
  value       = aws_secretsmanager_secret.this.id
}

output "secret_arn" {
  description = "Secret ARN."
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "Secret Name"
  value       = aws_secretsmanager_secret.this.name
}

output "secret_id_version" {
  description = "A pipe delimited combination of secret ID and version ID."
  value       = var.ignore_changes_to_secret_value ? data.aws_secretsmanager_secret_version.current_externally_managed[0].id : data.aws_secretsmanager_secret_version.current_fully_managed[0].id
}

output "secret_version_id" {
  description = "Unique identifier of this version of the secret."
  value       = var.ignore_changes_to_secret_value ? data.aws_secretsmanager_secret_version.current_externally_managed[0].version_id : data.aws_secretsmanager_secret_version.current_fully_managed[0].version_id
}
