# Domain Filtering Rule Group
resource "aws_networkfirewall_rule_group" "this" {
  capacity = tostring(var.capacity)
  name     = "${var.name_prefix}-domain-filtering" # using name prefix to ensure name uniqueness
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
        target_types         = var.enable_http_host ? ["HTTP_HOST", "TLS_SNI"] : ["TLS_SNI"]
        targets              = var.allowed_domains
      }
    }
  }
  tags = var.tags
}
