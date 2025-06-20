output "pull_policy" {
  description = "Metadata relating to the IAM policy that permits pulling this tenant's container images."
  value       = local.policy_outputs["pull"]
}

output "push_policy" {
  description = "Metadata relating to the IAM policy that permits pushing this tenant's container images."
  value       = local.policy_outputs["push"]
}

output "view_policy" {
  description = "Metadata relating to the IAM policy that permits viewing and describing this tenant's container images."
  value       = local.policy_outputs["view"]
}

output "repository_arns" {
  description = "Set of repository ARNs (corresponding to individial legacy repos or path prefixes ending in '/*') managed by this module."
  value       = toset(flatten(values(module.identity_policy_documents)[*].repository_arns))
}