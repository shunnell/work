<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metric_alarm"></a> [metric\_alarm](#module\_metric\_alarm) | ../cloudwatch_metric_alarm | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_metric_filter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metric_filter_alarms"></a> [metric\_filter\_alarms](#input\_metric\_filter\_alarms) | Alarms | <pre>map(object({<br/>    metric_filter = object({<br/>      metric_name                 = string<br/>      pattern                     = string<br/>      default_value               = optional(number)<br/>      log_group_name              = optional(string)<br/>      namespace                   = optional(string)<br/>      metric_transformation_value = optional(number)<br/>    })<br/>    alarm = object({<br/>      alarm_name          = string<br/>      alarm_description   = optional(string)<br/>      alarm_actions       = optional(list(string))<br/>      comparison_operator = string<br/>      evaluation_periods  = number<br/>      period              = number<br/>      statistic           = string<br/>      threshold           = number<br/>      dimensions          = optional(map(string))<br/>      tags                = optional(map(string))<br/>    })<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the CloudWatch Metric Filter and Alarm | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_arns"></a> [alarm\_arns](#output\_alarm\_arns) | Map of alarm names to their ARNs |
| <a name="output_alarm_ids"></a> [alarm\_ids](#output\_alarm\_ids) | Map of alarm names to their IDs |
| <a name="output_metric_filter_ids"></a> [metric\_filter\_ids](#output\_metric\_filter\_ids) | Map of metric filter names to their IDs |
| <a name="output_metric_filter_names"></a> [metric\_filter\_names](#output\_metric\_filter\_names) | Map of metric filter names to their actual names |
<!-- END_TF_DOCS -->
