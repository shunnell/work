module "awslbc_irsa_role" {
  count                        = var.enable_aws_load_balancer_controller ? 1 : 0
  source                       = "../service_account"
  use_name_as_iam_role_prefix  = true
  name                         = "aws-load-balancer-controller"
  cluster_name                 = var.cluster_name
  namespace                    = "kube-system"
  use_load_balancer_controller = true
  tags                         = var.tags
}

module "awslbc" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0
  # https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
  source       = "../../helm"
  release_name = "aws-load-balancer-controller"
  # NB: This domain is permitted through the non-prod egress firewall by FAB request, managed by IaC in "live". The
  # rule group which permits it in the "network" account is here:
  # https://us-east-1.console.aws.amazon.com/vpcconsole/home?region=us-east-1#NetworkFirewallRuleGroupDetails:name=network-platform-non-prod-inspection-infra-rule-group-domain-filtering;type=stateful;arn=arn_aws_network-firewall_us-east-1_975050075035_stateful-rulegroup~network-platform-non-prod-inspection-infra-rule-group-domain-filtering
  repository    = "https://aws.github.io/eks-charts"
  chart         = "aws-load-balancer-controller"
  namespace     = "kube-system"
  chart_version = "1.13.3"

  set = {
    "image.repository"     = "${local.image_path_root}/ecr-public/eks/aws-load-balancer-controller"
    "clusterName"          = var.cluster_name
    "region"               = data.aws_region.current.region
    "vpcId"                = var.vpc_id
    "backendSecurityGroup" = var.nodegroup_security_group_id
    "defaultTargetType"    = "ip"

    "serviceAccount.name"   = module.awslbc_irsa_role[0].service_account_name
    "serviceAccount.create" = false
  }
}
