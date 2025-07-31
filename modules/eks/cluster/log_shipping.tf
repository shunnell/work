locals {
  log_group_prefix = "${split("log-group:", module.eks.cloudwatch_log_group_arn)[0]}log-group:/aws/containerinsights/${var.cluster_name}"
}

module "log_shipping" {
  source          = "../../monitoring/cloudwatch_log_shipping_source"
  destination_arn = var.cloudwatch_log_shipping_destination_arn
  depends_on      = [module.eks.cluster_addons] # Log groups only exist once the cloudwatch addons are created
  log_group_arns = [
    module.eks.cloudwatch_log_group_arn,
    "${local.log_group_prefix}/application",
    "${local.log_group_prefix}/dataplane",
    "${local.log_group_prefix}/performance",
  ]
}
