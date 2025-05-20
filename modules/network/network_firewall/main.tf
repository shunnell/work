# Firewall Policy
resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.name_prefix}-policy" # using name prefix to ensure name uniqueness

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    dynamic "stateful_rule_group_reference" {
      for_each = var.rule_group_arns
      content {
        resource_arn = stateful_rule_group_reference.value
      }
    }

  }
  tags = var.tags
}

# Network Firewall
resource "aws_networkfirewall_firewall" "this" {
  name                = "${var.name_prefix}-firewall" # using name prefix to ensure name uniqueness
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id              = var.vpc_id
  delete_protection   = true

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings
    content {
      subnet_id = subnet_mapping.value
    }
  }
  tags = var.tags
}

# Logging Configuration
resource "aws_networkfirewall_logging_configuration" "this" {
  firewall_arn = aws_networkfirewall_firewall.this.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = var.alert_log_group_name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        logGroup = var.flow_log_group_name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
    log_destination_config {
      log_destination = {
        logGroup = var.tls_log_group_name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "TLS"
    }
  }
}
