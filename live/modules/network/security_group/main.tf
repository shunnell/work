resource "aws_security_group" "this" {
  description = var.description
  name_prefix = var.name_prefix
  name        = var.name
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = var.name })
}

resource "aws_security_group_rule" "allow_all_outbound" {
  // Only allowing TCP and UDP for all-outbound so we don't accidentally come to rely on ICMP
  for_each          = toset(var.allow_all_outbound_traffic ? ["tcp", "udp"] : [])
  from_port         = 0
  protocol          = each.value
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
  to_port           = 0
  type              = "egress"
}

module "rules" {
  source                                          = "../security_group_traffic"
  for_each                                        = var.rules
  description                                     = each.key
  ports                                           = each.value.ports
  security_group_id                               = aws_security_group.this.id
  target                                          = each.value.target
  type                                            = each.value.type
  create_explicit_egress_to_target_security_group = !var.allow_all_outbound_traffic
}
