module "alarms" {
  source       = "./eks-automated-monitoring"
  cluster_name = var.cluster_name
  tags         = var.tags
}
