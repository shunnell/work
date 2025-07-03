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
  cluster_addons                  = local.cluster_addon_configs
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
