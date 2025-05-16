output "repository_prefixes" {
  description = "ECR repository paths or prefixes (not ARNs) for repositories owned by this tenant"
  value       = local.tenant_repository_prefixes
}

output "pull_policy" {
  description = "Metadata relating to the IAM policy that permits pulling this tenant's container images"
  value       = local.policy_outputs["pull"]
}

output "push_policy" {
  description = "Metadata relating to the IAM policy that permits pushing this tenant's container images"
  value       = local.policy_outputs["push"]
}

output "view_policy" {
  description = "Metadata relating to the IAM policy that permits viewing container images, and describing images for this tenant's images"
  value       = local.policy_outputs["view"]
}
