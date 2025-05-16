data "aws_iam_policy_document" "this" {
  statement {
    sid       = "RegistryCommonAccess"
    actions   = local.common
    resources = length(local.repositories) > 0 ? ["*"] : [] # These permissions don't apply to individual repos
    dynamic "principals" {
      for_each = length(var.principals) > 0 ? [1] : []
      content {
        identifiers = var.principals
        type        = "AWS"
      }
    }
  }
  dynamic "statement" {
    for_each = var.action == "view" ? [1] : []
    content {
      sid       = "ViewAccess"
      actions   = local.view
      resources = local.repositories
      # TODO these are a little gross/duplicative, in that we take both AWS principals and arbitrary conditions. In the
      #   future it might be useful to simplify the module API to take a predetermined set of principal types (org OUs,
      #   static users, services, etc.) and generate the conditions internally so things are less confusing.
      dynamic "principals" {
        for_each = length(var.principals) > 0 ? [1] : []
        content {
          identifiers = var.principals
          type        = "AWS"
        }
      }
      dynamic "condition" {
        for_each = var.conditions
        content {
          values   = condition.value.values
          variable = condition.value.variable
          test     = condition.value.test
        }
      }
    }
  }
  dynamic "statement" {
    for_each = var.action == "pull" ? [1] : []
    content {
      sid = "PullAccess"
      # Does not imply view, some pulling principals (e.g. prod EKS) shouldn't grant metadata read permissions:
      actions   = local.pull
      resources = local.repositories
      dynamic "principals" {
        for_each = length(var.principals) > 0 ? [1] : []
        content {
          identifiers = var.principals
          type        = "AWS"
        }
      }
      dynamic "condition" {
        for_each = var.conditions
        content {
          values   = condition.value.values
          variable = condition.value.variable
          test     = condition.value.test
        }
      }
    }
  }
  dynamic "statement" {
    for_each = var.action == "pull_through" ? [1] : []
    content {
      sid = "PullThroughAccess"
      # Pull_through implies pull by definition:
      actions   = setunion(local.pull, local.pull_through)
      resources = local.repositories
      dynamic "principals" {
        for_each = length(var.principals) > 0 ? [1] : []
        content {
          identifiers = var.principals
          type        = "AWS"
        }
      }
      dynamic "condition" {
        for_each = var.conditions
        content {
          values   = condition.value.values
          variable = condition.value.variable
          test     = condition.value.test
        }
      }
    }
  }
  dynamic "statement" {
    for_each = var.action == "push" ? [1] : []
    content {
      sid = "PushAccess"
      # Push always implies pull, since I can't think of any circumstances where that would grant undesired access.
      actions   = setunion(local.pull, local.push)
      resources = local.repositories
      dynamic "principals" {
        for_each = length(var.principals) > 0 ? [1] : []
        content {
          identifiers = var.principals
          type        = "AWS"
        }
      }
      dynamic "condition" {
        for_each = var.conditions
        content {
          values   = condition.value.values
          variable = condition.value.variable
          test     = condition.value.test
        }
      }
    }
  }
}