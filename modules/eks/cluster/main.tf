module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = var.kuberenetes_version
  enable_irsa     = true
  depends_on      = [module.cluster_security_group]
  access_entries = merge(var.access_entries, {
    for arn in var.administrator_role_arns :
    "${arn}" => {
      principal_arn     = arn
      kubernetes_groups = ["cluster-admin"]
      type              = "STANDARD"
      tags              = var.tags
      policy_associations = {
        "AmazonEKSClusterAdminPolicy" = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  })
  node_security_group_additional_rules = {
    node_metrics_server_to_cluster = {
      # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3311
      description                   = "Cluster API to metrics-server"
      protocol                      = "tcp"
      from_port                     = 10251
      to_port                       = 10251
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
  cluster_addons = {
    # We set addon versions to most_recent in anticipation of this module defaulting that in the future:
    # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/5c8ac85c5c428779fd905c2819bb69fd518e7992/main.tf#L734
    vpc-cni = {
      # https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
      most_recent = true
      # Before compute because nodes will not fully function without it and adding it to an already-broken nodegroup
      # results in a 25+min timeout before terragrunt errors, which is lame for debug cycling.
      before_compute = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      # Before compute because we don't want things that launch early to provision volumes without EBS PVC provisioning
      # being the default:
      before_compute = true
    }
    kube-proxy = {
      # https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
      most_recent = true
    }
    # CoreDNS is always present regardless of whether it's installed as an addon, but the addon gives clearer visibility
    # into its versioning/upgrade-ability/health status:
    # https://www.reddit.com/r/aws/comments/tg2b57/eks_why_is_coredns_an_addon/?rdt=61433
    coredns = {
      most_recent = true
    }
    aws-guardduty-agent = {
      # GuardDuty is often auto-enabled from the outside via AWS Organizations (though that may change as Cloud City
      # gets firmer control over platform-only provisioning of EKS clusters and grandfathered-in clusters are removed),
      # but it doesn't hurt anything to manage it here as well:
      most_recent = true
    }
    eks-node-monitoring-agent = {
      most_recent = true
    }
    metrics-server = { # Supplies metrics to the HPA
      # NB: metrics-server's ApiService needs the cluster to access the metrics server at its default port, 10251.
      # That security group rule is added above.
      most_recent = true
    }
    kube-state-metrics = { # Supplies metrics for Prometheus
      most_recent = true
    }
    prometheus-node-exporter = { # Supplies metrics for Prometheus
      most_recent = true
    }
    amazon-cloudwatch-observability = {
      most_recent = true
    }
  }

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true
  cluster_additional_security_group_ids = concat(
    [module.cluster_security_group.id],
    var.additional_security_group_ids
  )

  # not setting to 'true' so that there are not conflicts with the 'terragrunter' role because:
  # "The specified access entry resource is already in use on this cluster"
  # enable_cluster_creator_admin_permissions = false

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids

  eks_managed_node_groups = local.node_group_configs

  tags = var.tags
}
