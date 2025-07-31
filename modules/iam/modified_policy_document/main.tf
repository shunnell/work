locals {
  policy_length = length(data.aws_iam_policy_document.policy.minified_json)
  effects       = var.require_effect == null ? ["Allow", "Deny"] : [title(lower(var.require_effect))]
}

data "aws_iam_policy_document" "policy" {
  dynamic "statement" {
    for_each = flatten([for p in var.policies : jsondecode(p)["Statement"]])
    content {
      effect        = statement.value["Effect"]
      sid           = var.require_sid ? statement.value["Sid"] : lookup(statement.value, "Sid", null)
      resources     = flatten([lookup(statement.value, "Resource", [])])
      not_resources = flatten([lookup(statement.value, "NotResource", [])])
      actions       = flatten([lookup(statement.value, "Action", [])])
      not_actions   = flatten([lookup(statement.value, "NotAction", [])])
      dynamic "condition" {
        for_each = concat(
          var.add_conditions_to_all_stanzas,
          [
            for test, conditions in lookup(statement.value, "Condition", []) :
            [for k, v in conditions : { test = test, variable = k, values = flatten([v]) }]
          ]...
        )
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
  lifecycle {
    postcondition {
      condition     = alltrue([for s in self.statement : contains(local.effects, s.effect)])
      error_message = "Input policies must be be deny-only or allow-only per var.require_effect"
    }
  }
}

