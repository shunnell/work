module "awslbc_irsa_role" {
  source                       = "../service_account"
  use_name_as_iam_role_prefix  = true
  name                         = "aws-load-balancer-controller"
  cluster_name                 = var.cluster_name
  namespace                    = "kube-system"
  use_load_balancer_controller = true
  tags                         = var.tags
}

module "awslbc" {
  # https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
  source       = "../../helm"
  release_name = "aws-load-balancer-controller"

  repository    = "${local.image_path_root}/helm/aws/eks-charts"
  chart         = "aws-load-balancer-controller"
  namespace     = "kube-system"
  chart_version = "1.11.0"

  set = {
    "image.repository"     = "${local.image_path_root}/ecr-public/eks/aws-load-balancer-controller"
    "clusterName"          = var.cluster_name
    "region"               = data.aws_region.current.name
    "vpcId"                = var.vpc_id
    "backendSecurityGroup" = var.nodegroup_security_group_id
    "defaultTargetType"    = "ip"

    "serviceAccount.name"   = module.awslbc_irsa_role.service_account_name
    "serviceAccount.create" = false
  }
}
