output "access_entries" {
  description = "Map of access entries created and their attributes"
  value       = module.eks.access_entries
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created - cluster logs"
  value       = module.eks.cloudwatch_log_group_arn
}

output "access_policy_associations" {
  description = "Map, keyed by accessing principal, of cluster access policy associations created and their attributes"
  value = { for v in values(module.eks.access_policy_associations) : v.principal_arn => {
    policy_arn    = v.policy_arn
    associated_at = v.associated_at
    modified_at   = v.modified_at
    cluster       = anytrue([for s in v.access_scope : (s["type"] == "cluster")])
    namespaces    = toset(flatten([[for s in v.access_scope : coalesce(s["namespaces"], [])]]))
  } }
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_iam_role_arn" {
  value       = module.eks.cluster_iam_role_arn
  description = "Cluster IAM role ARN"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS cluster"
}

output "vpc_id" {
  value       = var.vpc_id
  description = "The cluster's VPC ID"
}

output "cluster_security_group_id" {
  # We don't want to surface the "real" main cluster security group as that's internal-use-only. Our secondary group
  # is what folks should use if they want to e.g. add their own rules to it after the cluster is up.
  value       = module.cluster_security_group.id
  description = "ID of the cluster security group"
}

output "cluster_service_cidr" {
  value       = module.eks.cluster_service_cidr
  description = "The CIDR block where Kubernetes pod and service IP addresses are assigned from"
}

output "node_groups" {
  value = {
    for k, _ in var.node_groups : k => {
      arn          = module.eks.eks_managed_node_groups[k].node_group_arn
      asg_name     = module.eks.eks_managed_node_groups[k].node_group_autoscaling_group_names[0]
      iam_role_arn = module.eks.eks_managed_node_groups[k].iam_role_arn
      # We don't want to surface the "real" main cluster security group as that's internal-use-only. Our secondary group
      # is what folks should use if they want to e.g. add their own rules to it after the cluster is up.
      security_group_id = module.node_security_groups[k].id
      labels            = module.eks.eks_managed_node_groups[k].node_group_labels
    }
  }
}

output "oidc_provider" {
  value       = trimsuffix(module.eks.oidc_provider, "/")
  description = "The OpenID Connect identity provider (issuer URL without leading https:// or trailing slash)"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "The ARN of the OIDC Provider"
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}
