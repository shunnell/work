module "nexus_service_account" {
  source                      = "../eks/service_account"
  use_name_as_iam_role_prefix = true
  name                        = local.irsa_name
  cluster_name                = var.cluster_name
  namespace                   = local.namespace
  assume_role_condition_test  = "StringLike"
  create_service_account      = true
  tags                        = var.tags
  secret_arns                 = var.secret_arn
  depends_on                  = [kubernetes_namespace.nexus_namespace]
}