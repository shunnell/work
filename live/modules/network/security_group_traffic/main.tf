locals {
  target_sg             = startswith(var.target, "sg-")
  flip                  = var.type == "egress" && local.target_sg
  create_secondary_rule = local.flip && coalesce(var.create_explicit_egress_to_target_security_group, false)
}

resource "aws_security_group_rule" "primary" {
  description              = var.description
  protocol                 = coalesce(var.protocol, "tcp")
  from_port                = var.ports[0]
  to_port                  = var.ports[length(var.ports) - 1]
  type                     = local.flip ? "ingress" : var.type
  security_group_id        = local.flip ? var.target : var.security_group_id
  source_security_group_id = local.flip ? var.security_group_id : local.target_sg ? var.target : null
  cidr_blocks              = local.target_sg ? null : [var.target]
  self                     = var.target == "self" ? true : null
}

resource "aws_security_group_rule" "secondary" {
  count                    = local.create_secondary_rule ? 1 : 0
  description              = "explicit egress for: ${var.description}"
  protocol                 = coalesce(var.protocol, "tcp")
  from_port                = var.ports[0]
  to_port                  = var.ports[length(var.ports) - 1]
  type                     = "egress"
  security_group_id        = var.security_group_id
  source_security_group_id = var.target
}
