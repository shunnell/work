output "cluster_id" {
  description = "Cluster ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "Endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "node_group_instance_type" {
  description = "Instance type for the node group"
  value       = var.instance_type
}

output "node_group_ami_type" {
  description = "AMI type for the node group"
  value       = var.ami_type
}

output "node_group_capacity_type" {
  description = "Capacity type for the node group"
  value       = var.capacity_type
}

# output "eks_private_endpoint" {
#   description = "Private endpoint for the EKS cluster"
#   value       = aws_vpc_endpoint.eks.dns_entry[0].dns_name
# }