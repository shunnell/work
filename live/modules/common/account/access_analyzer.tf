module "access_analyzer" {
  source = "../../iam/tenant_baseline/access-analyzer"
  tags   = var.tags
}
