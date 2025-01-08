resource "aws_eks_cluster" "this" {
  name    = var.cluster_name
  version = var.cluster_version

  role_arn = var.existing_node_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  enabled_cluster_log_types = var.cluster_log_types

  tags = var.tags
}

resource "aws_eks_node_group" "this" {
  cluster_name  = aws_eks_cluster.this.name
  node_role_arn = var.existing_node_role_arn
  subnet_ids    = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = [var.instance_type]
  ami_type       = var.ami_type
  capacity_type  = var.capacity_type
  disk_size      = var.node_disk_size
}

resource "aws_security_group_rule" "allow_eks_to_vpc_endpoint" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = data.aws_security_group.vpc_endpoint_sg.id
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description       = "eks-${var.cluster_name}"
}

data "aws_security_group" "vpc_endpoint_sg" {
  filter {
    name   = "group-name"
    values = [var.vpc_endpoint_sg_name]
  }
}
