module "policy" {
  source         = "../modified_policy_document"
  require_effect = "deny"
  add_conditions_to_all_stanzas = length(var.bypass_for_principal_arns) == 0 ? [] : [{
    test     = "ArnNotLike"
    variable = "aws:PrincipalARN"
    values   = var.bypass_for_principal_arns
  }]
  max_length = 5120 # AWS-enforced max length limit for SCPs/RCPs.
  policies   = var.policies
}

resource "aws_organizations_policy" "policy" {
  description = var.description
  type        = var.service_control_policy ? "SERVICE_CONTROL_POLICY" : "RESOURCE_CONTROL_POLICY"
  content     = module.policy.json
  tags        = var.tags
  name        = var.name
}

resource "aws_organizations_policy_attachment" "attachment" {
  for_each  = var.organizational_units_or_account_ids
  policy_id = aws_organizations_policy.policy.id
  target_id = each.key
}