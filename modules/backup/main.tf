data "aws_iam_role" "existing_backup_role" {
  name = var.existing_backup_role_name
}

locals {
  schedule_crons = {
    hourly  = "cron(0 * * * ? *)"
    daily   = "cron(0 5 * * ? *)"
    weekly  = "cron(0 5 ? * 1 *)"
    monthly = "cron(0 5 1 * ? *)"
  }

  backup_schedule = lookup(local.schedule_crons, var.schedule_frequency, "cron(0 5 * * ? *)")

  tags = var.tags
}

resource "aws_backup_plan" "eks_ebs_plan" {
  name = var.backup_plan_name

  rule {
    rule_name         = var.backup_rule_name
    target_vault_name = "Default"
    schedule          = local.backup_schedule
    start_window      = var.start_window
    completion_window = var.completion_window

    lifecycle {
      delete_after = var.delete_after_days
    }

    recovery_point_tags = var.recovery_point_tags
  }
}

resource "aws_backup_selection" "eks_ebs_selection" {
  name         = "${keys(var.selection_tags)[0]}-${values(var.selection_tags)[0]}-Selection"
  iam_role_arn = data.aws_iam_role.existing_backup_role.arn
  plan_id      = aws_backup_plan.eks_ebs_plan.id

  dynamic "selection_tag" {
    for_each = var.selection_tags
    content {
      type  = "STRINGEQUALS"
      key   = selection_tag.key
      value = selection_tag.value
    }
  }
}
