module "external_dns_irsa_role" {
  source                      = "../service_account"
  use_name_as_iam_role_prefix = true
  name                        = "external-dns"
  cluster_name                = var.cluster_name
  namespace                   = kubernetes_namespace.namespaces["external-dns"].metadata[0].name
  use_external_dns            = true
  tags                        = var.tags
}