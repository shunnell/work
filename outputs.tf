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

output "cluster_security_group_id" {
  description = "The security group ID of the EKS cluster" 
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "vpc_endpoint_security_group_id" {
  description = "The security group ID of the VPC endpoint"
  value       = data.aws_security_group.vpc_endpoint_sg.id
  
}
