module "aurora_serverless_v2" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name                                                   = var.db_cluster_identifier
  engine                                                 = var.engine
  engine_mode                                            = "provisioned"
  engine_version                                         = var.engine_version
  storage_encrypted                                      = true
  database_name                                          = var.cluster_db_name
  master_username                                        = var.master_username
  manage_master_user_password                            = true
  manage_master_user_password_rotation                   = var.manage_master_user_password_rotation
  master_user_password_rotation_automatically_after_days = var.master_user_password_rotation_automatically_after_days
  create_db_subnet_group                                 = true
  db_subnet_group_name                                   = var.db_cluster_identifier
  vpc_id                                                 = var.vpc_id
  subnets                                                = var.subnet_ids
  backup_retention_period                                = 7
  apply_immediately                                      = var.apply_immediately
  skip_final_snapshot                                    = true
  iam_database_authentication_enabled                    = false
  cluster_performance_insights_enabled                   = true
  cluster_performance_insights_retention_period          = 465
  database_insights_mode                                 = "advanced"
  performance_insights_enabled                           = true
  enable_http_endpoint                                   = true
  create_security_group                                  = true
  security_group_rules                                   = var.security_group_rules
  enabled_cloudwatch_logs_exports                        = var.enabled_cloudwatch_logs_exports
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
