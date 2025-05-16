output "license_base64" {
  description = "license in base64"
  value       = jsondecode(data.aws_secretsmanager_secret_version.current_externally_managed[0].secret_string)
  sensitive   = true
}
