include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//monitoring/cloudwatch_metric_filter_alarms"
}

inputs = {
  metric_filter_alarms = {
    no_mfa_console = {
      metric_filter = {
        metric_name                 = "no-mfa-console-signin-metric"
        pattern                     = "{ ($.userIdentity.type = \"IAMUser\") && ($.userIdentity.sessionContext.attributes.mfaAuthenticated = \"false\") && ($.sessionCredentialFromConsole = \"true\") }"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "no-mfa-console-signin-alarm"
        alarm_description   = "Alarm for console sign-in without MFA"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    root_usage = {
      metric_filter = {
        metric_name                 = "root-usage-metric"
        pattern                     = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "root-usage-alarm"
        alarm_description   = "Alarm for AWS root account usage"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    iam_changes = {
      metric_filter = {
        metric_name                 = "iam-changes-metric"
        pattern                     = "{($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "iam-changes-alarm"
        alarm_description   = "Alarm for IAM policy changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    }
  }
}