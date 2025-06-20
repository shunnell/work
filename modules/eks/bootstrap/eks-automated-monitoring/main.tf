#### KMS Key

module "kms_key" {
  source      = "../../../kms/key"
  description = "KMS Key to encrypt CW Alarm data"
  alias       = "${local.name}/key"
  policy_stanzas = {
    "Enable Cloudwatch to access KMS KEY Permissions" = {
      actions = ["kms:Decrypt", "kms:GenerateDataKey*", "kms:DescribeKey"]
      conditions = [{
        test     = "StringEquals"
        variable = "kms:KeySpec"
        values   = ["SYMMETRIC_DEFAULT"]
      }]
      principals = {
        "Service" = ["cloudwatch.amazonaws.com"]
      }
    }
  }
  tags = var.tags
}

#### SNS Topic To Sens EKS Alarm Notification #########

module "eks_alarm_sns" {
  source          = "../../../sns"
  topic_name      = "${local.name}-cw-eks-alarm"
  kms_key_id      = module.kms_key.id
  delivery_policy = <<-EOF
    {
      "http": {
        "defaultHealthyRetryPolicy": {
          "minDelayTarget": 20,
          "maxDelayTarget": 20,
          "numRetries": 3,
          "numMaxDelayRetries": 0,
          "numNoDelayRetries": 0,
          "numMinDelayRetries": 0,
          "backoffFunction": "linear"
        },
        "disableSubscriptionOverrides": false,
        "defaultRequestPolicy": {
          "headerContentType": "text/plain; charset=UTF-8"
        }
      }
    }
    EOF
  subscriptions = [{
    protocol = "email"
    endpoint = var.sns_topic_email
  }]
  tags = var.tags
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = local.name
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        local.account_id,
      ]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      module.eks_alarm_sns.arn,
    ]
    sid = "AllowSNSTopicAlarms"
  }
}

resource "aws_sns_topic_policy" "eks_alarm_sns_policy" {
  arn    = module.eks_alarm_sns.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

######################## Cloudwatch Alarms ##############################
module "cw_alarms" {
  source = "../../../monitoring/cloudwatch_metric_alarm"

  for_each = var.alarms

  create_metric_alarm                   = try(each.value.create_metric_alarm, var.defaults.create_metric_alarm, true)
  alarm_name                            = try("${each.value.alarm_prefix}-${var.cluster_name}", "${var.defaults.alarm_prefix}-${var.cluster_name}")
  alarm_description                     = try(each.value.alarm_description, var.defaults.alarm_description, null)
  comparison_operator                   = try(each.value.comparison_operator, var.defaults.comparison_operator)
  evaluation_periods                    = try(each.value.evaluation_periods, var.defaults.evaluation_periods)
  threshold                             = try(each.value.threshold, var.defaults.threshold, null)
  threshold_metric_id                   = try(each.value.threshold_metric_id, var.defaults.threshold_metric_id, null)
  unit                                  = try(each.value.unit, var.defaults.unit, null)
  metric_name                           = try(each.value.metric_name, var.defaults.metric_name, null)
  namespace                             = try(each.value.namespace, var.defaults.namespace, null)
  period                                = try(each.value.period, var.defaults.period, null)
  statistic                             = try(each.value.statistic, var.defaults.statistic, null)
  actions_enabled                       = try(each.value.actions_enabled, var.defaults.actions_enabled, true)
  datapoints_to_alarm                   = try(each.value.datapoints_to_alarm, var.defaults.datapoints_to_alarm, null)
  dimensions                            = merge(try(each.value.dimensions, var.defaults.dimensions, {}), { ClusterName = var.cluster_name })
  alarm_actions                         = try(each.value.alarm_actions, [(module.eks_alarm_sns.arn)], null)
  insufficient_data_actions             = try(each.value.insufficient_data_actions, var.defaults.insufficient_data_actions, null)
  ok_actions                            = try(each.value.ok_actions, [(module.eks_alarm_sns.arn)], null)
  extended_statistic                    = try(each.value.extended_statistic, var.defaults.extended_statistic, null)
  treat_missing_data                    = try(each.value.treat_missing_data, var.defaults.treat_missing_data, "missing")
  evaluate_low_sample_count_percentiles = try(each.value.evaluate_low_sample_count_percentiles, var.defaults.evaluate_low_sample_count_percentiles, null)
  metric_query                          = try(each.value.metric_query, var.defaults.metric_query, [])

  tags = var.tags
}
