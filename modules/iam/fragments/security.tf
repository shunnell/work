data "aws_iam_policy_document" "tenant_security_restrictions" {
  statement {
    sid    = "DenySecurityHubModifications"
    effect = "Deny"
    actions = [
      # Disable tenant modification of security hub behavior.
      # TODO/NOTE: This may be too restrictive or incorrect, and tenants should be allowed to modify SecurityHub in
      #   their sandbox accounts (so long as they can't modify the aggregating/master securityhub account).
      "securityhub:Delete*",
      "securityhub:Disable*",
      "securityhub:Disassociate*",
      "securityhub:Start*",
      "securityhub:Enable*",
      "securityhub:Update*",
      "securityhub:BatchDeleteAutomationRules",
      "securityhub:BatchDisableStandards",
      "securityhub:BatchImportFindings",
      "securityhub:BatchUpdateStandardsControlAssociations",
      "securityhub:BatchUpdateAutomationRules",
      "securityhub:BatchUpdateFindings",
      "securityhub:ConnectorRegistrationsV2",
      "securityhub:CreateAutomationRule",
      "securityhub:CreateAutomationRuleV2",
      "securityhub:InviteMembers",
      "securityhub:TagResource",
      "securityhub:UntagResource",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "DenyNonReadOnlyInspectorActions"
    effect = "Deny"
    not_actions = [
      "inspector2:ListCoverage",
      "inspector2:ListFindings",
      "inspector2:BatchGet*",
    ]
    resources = ["arn:aws:inspector2:*:*:owner/*", "arn:aws:inspector2:*:*:finding/*", ]
  }
}
