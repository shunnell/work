module "slow_logs" {
  source         = "../monitoring/cloudwatch_log_group"
  log_group_name = "/aws/elasticache/${var.name}/slow-log"
  tags           = var.tags
}

module "engine_logs" {
  source         = "../monitoring/cloudwatch_log_group"
  log_group_name = "/aws/elasticache/${var.name}/engine-log"
  tags           = var.tags
}

module "shipping" {
  source          = "../monitoring/cloudwatch_log_shipping_source"
  log_group_arns  = [module.slow_logs.cloudwatch_log_group_arn, module.engine_logs.cloudwatch_log_group_arn]
  tags            = var.tags
  destination_arn = var.logs_destination_arn
}
