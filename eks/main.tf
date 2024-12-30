resource "aws_eks_cluster" "this" {
  name    = var.cluster_name
  version = var.cluster_version

  role_arn = var.node_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = var.cluster_log_types

  tags = var.tags
}

resource "aws_eks_node_group" "this" {
  # for_each      = var.node_groups
  cluster_name  = aws_eks_cluster.this.name
  node_role_arn = var.node_role_arn
  subnet_ids    = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = [var.instance_type]
  ami_type       = var.ami_worker
  capacity_type  = var.capacity_type
  disk_size      = var.node_disk_size

}
