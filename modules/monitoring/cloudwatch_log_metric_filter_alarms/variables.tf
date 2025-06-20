variable "metric_filter_alarms" {
  description = "Alarms"
  type = map(object({
    metric_filter = object({
      metric_name                 = string
      pattern                     = string
      default_value               = optional(number)
      log_group_name              = optional(string)
      namespace                   = optional(string)
      metric_transformation_value = optional(number)
    })
    alarm = object({
      alarm_name          = string
      alarm_description   = optional(string)
      alarm_actions       = optional(list(string))
      comparison_operator = string
      evaluation_periods  = number
      period              = number
      statistic           = string
      threshold           = number
      dimensions          = optional(map(string))
      tags                = optional(map(string))
    })
  }))
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the CloudWatch Metric Filter and Alarm"
  default     = {}
}
