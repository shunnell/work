module "aurora_serverless_v2" {
  source = "git::https://gitlab.cloud-city/terraform-aws-modules/terraform-aws-rds-aurora.git"

  name                                          = var.db_cluster_identifier
  engine                                        = var.engine
  engine_mode                                   = "provisioned"
  engine_version                                = var.engine_version
  storage_encrypted                             = true
  database_name                                 = var.cluster_db_name
  master_username                               = var.master_username
  manage_master_user_password                   = true
  create_db_subnet_group                        = true
  db_subnet_group_name                          = var.db_cluster_identifier
  vpc_id                                        = var.vpc_id
  subnets                                       = var.subnet_ids
  backup_retention_period                       = 7
  apply_immediately                             = false
  skip_final_snapshot                           = true
  iam_database_authentication_enabled           = false
  cluster_performance_insights_enabled          = true
  cluster_performance_insights_retention_period = 7
  enable_http_endpoint                          = true
  create_security_group                         = true
  enabled_cloudwatch_logs_exports               = var.enabled_cloudwatch_logs_exports
  serverlessv2_scaling_configuration = {
    min_capacity             = var.min_capacity
    max_capacity             = var.max_capacity
    seconds_until_auto_pause = var.seconds_until_auto_pause
  }
  cluster_timeouts = {
    create = var.create_timeout
    delete = var.delete_timeout
    update = var.update_timeout
  }
  instance_class = "db.serverless"
  instances = {
    for name in var.instance_names : "${name}" => {}
  }
  cluster_tags = var.tags
}

module "rds_security_rules" {
  source                                          = "../network/security_group_traffic"
  for_each                                        = var.inbound_security_group_ids
  description                                     = each.key
  ports                                           = [module.aurora_serverless_v2.cluster_port]
  security_group_id                               = module.aurora_serverless_v2.security_group_id
  target                                          = each.value
  type                                            = "egress"
  create_explicit_egress_to_target_security_group = true
}

module "target_security_rules" {
  source                                          = "../network/security_group_traffic"
  for_each                                        = var.inbound_security_group_ids
  description                                     = each.key
  ports                                           = [module.aurora_serverless_v2.cluster_port]
  security_group_id                               = each.value
  target                                          = module.aurora_serverless_v2.security_group_id
  type                                            = "egress"
  create_explicit_egress_to_target_security_group = true
}
