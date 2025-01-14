output "cluster_id" {
  description = "Cluster ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "Endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "node_group_ids" {
  description = "Node Group IDs"
  value       = aws_eks_node_group.this[*].id
}

output "node_group_instance_types" {
  description = "Instance type for the node group"
  value       = aws_eks_node_group.this[*].instance_types
}

output "node_group_ami_types" {
  description = "AMI type for the node group"
  value       = aws_eks_node_group.this[*].ami_type
}

output "node_group_capacity_types" {
  description = "Capacity type for the node group"
  value       = aws_eks_node_group.this[*].capacity_type
}

output "cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  # value       = module.eks.cluster_security_group_id
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

