module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.37.1" # Update as needed; only pinned for consistency, not something about this specific version.
  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version
  enable_irsa     = true
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
  node_security_group_use_name_prefix = false
  node_security_group_name            = "platform/eks/${var.cluster_name}/nodes/all"
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
  kms_key_deletion_window_in_days = 7 # The minimum
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true
  # The cluster security group is the SG in which the cluster control plane runs. The control plane is a separate,
  # AWS-internal service that orchestrates the cluster, but does not run pods or user code. The cluster is what you
  # connect to when you run kubectl or update manifests; it's also what nodes talk to in order to get workloads/pods to
  # run, publish health metrics, etc. As a result, the cluster's SG doesn't need much access--compared to nodes and
  # pods, which may need lots of service-specific access.
  cluster_security_group_name            = "platform/eks/${var.cluster_name}/cluster/internal"
  cluster_security_group_use_name_prefix = false
  cluster_security_group_additional_rules = {
    control_plane_cidrs = {
      # All clusters can be accessed via the VPN CIDR; access to the VPN in a given cluster's VPC is controlled via
      # Okta group membership.
      description = "Access kubernetes control plane via platform-managed CIDRs"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = var.kubernetes_control_plane_allowed_cidrs
    }
    # This replaces the access needed by the outbound rule on the EKS-managed SG which we remove per the "Programmatic
    # modification of the AWS-created EKS "Cluster security group" section in the README.
    cluster_to_nodes = {
      description                = "Allow cluster to access nodes"
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }
  # not setting to 'true' so that there are not conflicts with the 'terragrunter' role because:
  # "The specified access entry resource is already in use on this cluster"
  enable_cluster_creator_admin_permissions = false
  cluster_enabled_log_types                = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_id                                   = var.vpc_id
  subnet_ids                               = var.subnet_ids
  cluster_addons                           = local.cluster_addon_configs
  eks_managed_node_groups                  = local.node_group_configs
  tags                                     = var.tags
}
