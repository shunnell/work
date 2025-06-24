data "aws_wafregional_subscribed_rule_group" "managed" {
  count = var.managed_rule_name != "" && var.managed_rule_id == "" ? 1 : 0
  name  = var.managed_rule_name
}

locals {
  effective_managed_rule_id = (
    var.managed_rule_id != "" ?
    var.managed_rule_id :
    data.aws_wafregional_subscribed_rule_group.managed[0].id
  )
}

resource "aws_wafregional_web_acl" "this" {
  name        = "${var.name_prefix}-waf"
  metric_name = "${var.name_prefix}-waf-metric"

  default_action {
    type = "ALLOW"
  }

  rule {
    # Identify the managed rule group by its ID
    rule_id  = local.effective_managed_rule_id
    priority = 1
    type     = "REGULAR"

    action {
      type = "BLOCK"
    }
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-waf" })
}

resource "aws_wafregional_web_acl_association" "this" {
  resource_arn = var.resource_arn
  web_acl_id   = aws_wafregional_web_acl.this.id
}
