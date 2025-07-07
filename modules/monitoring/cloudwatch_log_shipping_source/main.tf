locals {
  log_group_names = [for arn in var.log_group_arns : regex("^arn:aws:logs:\\S*:\\d*:log-group:(\\S+)(:[*])?$", arn)[0]]
}

resource "aws_cloudwatch_log_subscription_filter" "subscribe_single_log" {
  name            = "CloudCityLogsToManagementAccount-${local.log_group_names[count.index]}" # TODO
  count           = length(var.log_group_arns)
  log_group_name  = local.log_group_names[count.index]
  role_arn        = module.cwlg_subscription_filter_role.role_arn
  filter_pattern  = ""
  destination_arn = var.destination_arn
  depends_on      = [time_sleep.wait]
}


# NB: aws_cloudwatch_log_account_policy is a special resource. It uses its IAM role internally for cross-account
# purposes. That means that, somewhere deep in the undocumented guts of AWS, it reads information about that role from
# some internal source of truth that is different than the SoT usually used for other, single-account-oriented things
# that can have an IAM attached. That cross-account source of truth is *eventually consistent*. Even after the IAM role
# is successfully created (after it can, say, produce outputs in Terraform or be used in a data variable, viewed in the
# UI, or passed around as a Terragrunt dependency value), the subscription filter object can't "see" it right away.
# This situation causes Terraform applies to fail with errors like:
# "ValidationException: Make sure you have given CloudWatch Logs permission to assume the provided role."
# The fix, ugly as it is, is to simply wait: we bake in a sleep below, but the amount of time it takes before the
# subscription filter can see the role is still highly variable, so a repeated "apply" may be necessary in some cases
# this unfortunate situation should probably be remedied with a bug report/fix to the "aws" terraform provider to have
# it internally retry/poll the subscription filter object some number of times until the role becomes available.
resource "time_sleep" "wait" {
  depends_on = [
    module.cwlg_subscription_filter_role
  ]
  create_duration = "15s" # 5 was too little consistently, 10 was 50/50, 15 seems OK 90% of the time.
}
