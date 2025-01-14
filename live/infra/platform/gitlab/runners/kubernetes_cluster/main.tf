# TODO this folder contains a commented bulk import of Terraform from the gitlab-iac repo:
#   https://gitlab.cloud-city/cloud-city-infra/gitlab-iac, minus resources moved into the adjacent kubernetes_resources
#   submodule.
#   Code in here is to be uncommented, 'terraform import'ed into the statefile, and then massaged until the plan runs
#   clean. This will be difficult, as diff was added to this code without plan/applying, and a LOT of
#   clickops/reconfiguration of the resources it managed has also happened in the intervening time.
#   Do not make any ticket-related changes to this code until it is uncommented and imported where possible and removed (either
#   by deleting resources and leaving comments about what exists unmanaged by TF, or by data-variable-ifying things to
#   at least encode dependency on things created via ClickOps).


# TODO we should move most of this code to be an invocation of our proper VPC and EKS modules.


# Data variables used in order to verify that hardcoded IDs exist. Ugly, but at least it's checked.
data "aws_subnet" "eks_subnet_1" {
  id     = "subnet-0d0765e05822f5f87"
  vpc_id = "vpc-01912bb2c7a00113e"
}

data "aws_subnet" "eks_subnet_2" {
  id     = "subnet-03d839cf71edb88ad"
  vpc_id = "vpc-01912bb2c7a00113e"
}

resource "aws_eks_cluster" "gitlab_runner_cluster" {
  name     = var.runner_eks_cluster_name
  role_arn = aws_iam_role.eks_role.arn

  # NB this parameter was set to false when importing this resource, since the default of 'true' would have torn down
  # and re-created the cluster, which seems bad. It's not false for any specific reason other than that.
  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids = [
      data.aws_subnet.eks_subnet_1.id,
      data.aws_subnet.eks_subnet_2.id
    ]
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceControllerPolicy,
  ]
}

# TODO the node group has drifted a LOT, needs to be patched up separately from the rest of stuff in this family.
#     specifically, the node group managed here is scaled into 0 (should probably be deleted then?) and drifted in many
#     other ways as well. A "_v2" suffixed nodegroup exists which is in use, probably created via clickops. Untangling
#     that will be tracked in https://jira.fan.gov/browse/CCP-368 and probably shouldn't be done ad-hoc before then
#     without reason.
# resource "aws_eks_node_group" "eks_node_group" {
#   cluster_name    = data.aws_eks_cluster.cluster.name
#   node_group_name = "dos_gitlab_central_runner_node_group_v2"
#   node_role_arn   = aws_iam_role.node_group_role.arn
#   subnet_ids = [
#     data.aws_subnet.eks_subnet_1.id,
#     data.aws_subnet.eks_subnet_2.id
#   ]
#
#   scaling_config {
#     desired_size = 2
#     max_size     = 6
#     min_size     = 1
#   }
#
#   depends_on = [
#     aws_iam_role_policy_attachment.ng_AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.ng_AmazonEC2ContainerRegistryReadOnly,
#     aws_iam_role_policy_attachment.ng_AmazonEKS_CNI_Policy
#
#   ]
# }
