# This data resource, on the other hand, should stick around in perpetuity. Because auth tokens and endpoints can
# change, re-fetching them to initialize the helm/k8s providers below makes sense. The auth settings pass the sniff
# test for "should it be tracked in state/input/output or is a data variable OK" on these criteria:
# - Is it explicitly instantiated? No, eks auth is not.
# - Will it ever need to be deleted? No, it'll be deleted (or not) with the cluster itself, which SHOULD be tracked
#   in state (see TODO above).
data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = var.runner_eks_cluster_name
}

provider "helm" {
  kubernetes {
    host                   = var.runner_cluster_endpoint
    cluster_ca_certificate = base64decode(var.runner_cluster_ca_data) # aws_eks_cluster.gitlab_runner_cluster.certificate_authority[0].data
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  }
}

provider "kubernetes" {
    host                   = var.runner_cluster_endpoint
    cluster_ca_certificate = base64decode(var.runner_cluster_ca_data) # aws_eks_cluster.gitlab_runner_cluster.certificate_authority[0].data
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
}
