module "security_group" {
  source      = "../network/security_group"
  name        = var.name
  description = var.description
  rules       = var.security_group_rules
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_elasticache_subnet_group" "this" {
  name        = var.name
  description = var.description
  tags        = var.tags
  subnet_ids  = var.subnet_ids
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = var.name
  description                = var.description
  node_type                  = var.node_type
  engine                     = var.engine
  security_group_ids         = [module.security_group.id]
  snapshot_retention_limit   = var.snapshot_retention_limit
  tags                       = var.tags
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  automatic_failover_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auto_minor_version_upgrade = true
  num_cache_clusters         = var.num_cache_clusters
  cluster_mode               = "disabled" # To do cluster mode should be disabled
  transit_encryption_mode    = "required"
  maintenance_window         = "sat:09:00-sat:23:59"
  snapshot_window            = "00:00-08:59"
  auth_token_update_strategy = "ROTATE"
  auth_token                 = data.aws_secretsmanager_secret_version.current.secret_string

  log_delivery_configuration {
    destination      = module.slow_logs.cloudwatch_log_group_name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = module.engine_logs.cloudwatch_log_group_name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
}
