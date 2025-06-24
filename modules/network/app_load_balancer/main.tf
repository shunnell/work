locals {
  processed_tenants = {
    for tenant_key, cfg in var.tenants :
    tenant_key => merge(
      {
        protocol          = lookup(cfg, "protocol", "HTTP")
        health_check_path = lookup(cfg, "health_check_path", "/")
      },
      cfg
    )
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP(S) from Internet"
  vpc_id      = var.vpc_id
  ingress {
    description = "Allow HTTP from approved sources"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidrs
  }

  ingress {
    description = "Allow HTTPS from approved sources"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #TODO: Restrict this to known IP ranges before applying
  }
  tags = var.tags
}

locals {
  sg_ids = [aws_security_group.alb.id]
}

resource "aws_lb" "this" {
  name                       = "${var.name_prefix}-alb"
  load_balancer_type         = "application"
  internal                   = false
  subnets                    = var.subnets
  security_groups            = local.sg_ids
  enable_deletion_protection = false

  tags = merge(var.tags, { Name = "${var.name_prefix}-alb" })
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "tenant" {
  for_each = local.processed_tenants

  name     = "${var.name_prefix}-${each.key}-tg"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = each.value.health_check_path
    protocol            = each.value.protocol
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-${each.key}-tg" })
}

resource "aws_lb_listener_rule" "tenant" {
  for_each = local.processed_tenants

  listener_arn = aws_lb_listener.https.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tenant[each.key].arn
  }

  condition {
    host_header {
      values = [each.value.host_header]
    }
  }
}

resource "aws_wafregional_web_acl_association" "this" {
  count        = var.waf_web_acl_id != null ? 1 : 0
  resource_arn = aws_lb.this.arn
  web_acl_id   = var.waf_web_acl_id
}
