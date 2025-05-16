include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/monitoring/cloudwatch_metric_filter_alarms"
}

inputs = {
  metric_filter_alarms = {
    log_failures = {
      metric_filter = {
        metric_name                 = "cloudcity-splunk-shipper-failure"
        namespace                   = "Security_checks"
        pattern                     = "."
        metric_transformation_value = 1
        log_group_name              = "cloudcity-splunk-shipper-failures"
      }
      alarm = {
        alarm_name          = "CloudCity Splunk Shipper Failures"
        alarm_description   = "This alarm is triggered when the number of log failures exceeds 1 in a 5 minute period."
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
      }
    }
  }
}
