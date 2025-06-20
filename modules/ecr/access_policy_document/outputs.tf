output "json" {
  description = "an aws_iam_policy_document object"
  value       = data.aws_iam_policy_document.this.json
}

output "repository_arns" {
  description = "Set of repository ARNs managed by this document"
  value       = local.repositories
}