resource "aws_sns_topic" "this" {
  name              = var.topic_name
  kms_master_key_id = var.kms_key_id
  tags              = var.tags
  delivery_policy   = var.delivery_policy
  policy            = var.topic_policy
}

resource "aws_sns_topic_subscription" "this" {
  for_each = { for sub in var.subscriptions : sub.endpoint => sub }

  topic_arn            = aws_sns_topic.this.arn
  protocol             = each.value.protocol
  endpoint             = each.value.endpoint
  filter_policy        = each.value.filter_policy
  raw_message_delivery = each.value.raw_message_delivery
}
