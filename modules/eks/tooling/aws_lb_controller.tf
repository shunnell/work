module "awslbc_irsa_role" {
  count = local.deploy_lb ? 1 : 0

  source = "../service_account"

  use_name_as_iam_role_prefix  = true
  name                         = "aws-load-balancer-controller"
  cluster_name                 = var.cluster_name
  namespace                    = "kube-system"
  use_load_balancer_controller = true

  tags = var.tags
}

module "awslbc" {
  count = local.deploy_lb ? 1 : 0

  # https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
  source = "../../argocd/application"

  argocd_namespace        = var.argocd_namespace
  aws_ecr_service_account = var.aws_ecr_service_account

  app_helm_chart_repo    = "${local.internal_helm_path_root}/eks"
  app_helm_chart         = "aws-load-balancer-controller"
  app_namespace          = "kube-system"
  app_helm_chart_version = var.aws_lbc_helm_chart_version
  self_heal              = true

  app_helm_values = <<-YAML
    replicaCount: 1
    image:
      repository: ${local.image_path_root}/ecr-public/eks/aws-load-balancer-controller
    clusterName: ${var.cluster_name}
    region: ${local.region}
    vpcId: ${var.vpc_id}
    backendSecurityGroup: ${var.nodegroup_security_group_id}
    serviceAccount:
      create: false
      name: ${module.awslbc_irsa_role[0].service_account_name}
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        memory: 128Mi
    # TODO : set the following when tenants stop using Ingresses
    # ingressClassParams:
    #   create: false
    # createIngressClassResource: false
    # controllerConfig:
    #   featureGates:
    #     ServiceTypeLoadBalancerOnly: true
    YAML
}
