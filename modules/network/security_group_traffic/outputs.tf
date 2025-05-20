output "rule_ids" {
  description = "IDs of any rules created on 'target' or 'security_group_id'. At least one element will be present; two if 'create_explicit_egress_to_target_security_group' was set."
  value = compact([
    aws_security_group_rule.primary.id,
    local.create_secondary_rule ? aws_security_group_rule.secondary[0].id : null
  ])
}
