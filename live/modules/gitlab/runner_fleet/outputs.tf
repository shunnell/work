output "runner_iam_role_arn" {
  description = "ARN of the IAM role runners will use inside the EKS cluster"
  value       = module.runner_iam_role.iam_role_arn
}

output "runner_namespace" {
  description = "Namespace containing these runners (and nothing else)"
  value       = local.runner_fleet_name
}
