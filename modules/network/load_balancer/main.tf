locals {
  lb_type            = "${substr(var.load_balancer_type, 0, 1)}lb"
  load_balancer_name = "${var.name_prefix}-${local.lb_type}"
  sg_rules = flatten([
    for p, _ in var.target_ports : [
      for k, v in var.target_rules : {
        type        = v.type
        ports       = [p]
        target      = v.target
        description = "${k} :: port ${p}"
      }
    ]
  ])
}

module "lb_sg" {
  source = "../security_group"
  vpc_id = var.vpc_id
  name   = "${local.load_balancer_name}-sg"
  rules = {
    for r in local.sg_rules : r.description => {
      type   = r.type
      ports  = r.ports
      target = r.target
    }
  }
  tags = var.tags
}

resource "aws_lb" "load_balancer" {
  name               = local.load_balancer_name
  load_balancer_type = var.load_balancer_type
  subnets            = var.subnet_ids
  security_groups    = [module.lb_sg.id]

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = true
  internal                         = true
  preserve_host_header             = true

  tags = var.tags
}

resource "aws_lb_target_group" "tg" {
  for_each = var.target_ports

  name               = "${local.load_balancer_name}-${each.key}-tg"
  port               = each.key
  protocol           = each.value.protocol
  vpc_id             = var.vpc_id
  proxy_protocol_v2  = each.value.proxy_protocol_v2
  preserve_client_ip = each.value.preserve_client_ip
  target_type        = each.value.target_type

  health_check {
    path              = each.value.health_check.path
    protocol          = each.value.health_check.protocol
    timeout           = 2
    healthy_threshold = 2
  }

  tags = var.tags
}

resource "aws_lb_listener" "listener" {
  for_each = var.target_ports

  load_balancer_arn = aws_lb.load_balancer.arn
  port              = each.key
  protocol          = each.value.protocol

  default_action {
    # Note: redirects, responses, and other traffic management will be handled by the API Gateway controller
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  tags = var.tags

  lifecycle {
    replace_triggered_by = [
      aws_lb_target_group.tg[each.key]
    ]
  }
}
