# Firewall Policy
resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.name_prefix}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.this.arn
    }

  }
}

# Domain Filtering Rule Group
resource "aws_networkfirewall_rule_group" "this" {
  capacity = var.capacity
  name     = "${var.name_prefix}-domain-filtering"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = var.home_net_cidrs
        }
      }
    }

    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.allowed_domains
      }
    }
  }
}

# Network Firewall
resource "aws_networkfirewall_firewall" "this" {
  name                = "${var.name_prefix}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id              = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings
    content {
      subnet_id = subnet_mapping.value
    }
  }
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
