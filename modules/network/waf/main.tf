data "aws_lb" "this" {
  name = "${var.name_prefix}-alb"
}

resource "aws_wafregional_web_acl" "this" {
  name        = "${var.name_prefix}-waf"
  metric_name = "${var.name_prefix}-waf-metric"

  default_action {
    type = "ALLOW"
  }

  rule {
    priority = 1
    action {
      type = "BLOCK"
    }
    rule_id = var.managed_rule_id
    type    = "GROUP"
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-waf" })
}

resource "aws_wafregional_web_acl_association" "this" {
  resource_arn = data.aws_lb.this.arn
  web_acl_id   = aws_wafregional_web_acl.this.id
}
