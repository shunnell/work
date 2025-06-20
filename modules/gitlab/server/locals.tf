locals {
  irsa_name        = "gitlab-${var.irsa_name}"
  rds_ext_secret   = "gitlab-aws-${var.rds_secret}"
  redis_ext_secret = "gitlab-aws-${var.redis_secret}"
  tags = merge(
    {
      # For human visibility:
      "gitlab" = var.release_name
      # For AWS association with the parent EKS, or for human searches for 'all things related to this cluster':
      "eks:cluster-name" : var.cluster_name
    },
    var.tags
  )
}
