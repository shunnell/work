resource "aws_eks_cluster" "this" {
  name    = var.cluster_name
  version = var.kubernetes_version

  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  enabled_cluster_log_types = var.cluster_log_types

  tags = var.tags
}

resource "aws_eks_node_group" "this" {
  count         = length(var.node_groups)
  cluster_name  = aws_eks_cluster.this.name
  node_role_arn = var.node_groups[count.index].node_role_arn
  subnet_ids    = var.subnet_ids

  scaling_config {
    desired_size = var.node_groups[count.index].desired_size
    min_size     = var.node_groups[count.index].min_size
    max_size     = var.node_groups[count.index].max_size
  }

  node_group_name = var.node_groups[count.index].name

  instance_types = [var.node_groups[count.index].instance_type]
  ami_type       = var.node_groups[count.index].ami_type
  capacity_type  = var.node_groups[count.index].capacity_type
  disk_size      = var.node_groups[count.index].disk_size
}

resource "aws_security_group_rule" "this" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = var.vpc_endpoint_sg_id
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description              = var.cluster_name
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
  addon_version = var.coredns_version
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
  addon_version = var.kube_proxy_version
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
  addon_version = var.vpc_cni_version
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "amazon-cloudwatch-metrics"
  addon_version = var.cloudwatch_observability_version
}