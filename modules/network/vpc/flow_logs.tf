# Emit flow logs to a CWLG, and then ship that CWLG to Splunk via firehose and a remote destination.
# TODO this is going to be very inefficient and expensive. Instead, this code should be replaced with a direct-to-firehose
# cross-account write to the firehose shipping to Splunk. That'll require changes to log shipping code, namely:
# 1. Update the Firehose destination module with cross-account support per https://docs.aws.amazon.com/vpc/latest/userguide/firehose-cross-account-delivery.html
# 2. Put in place a new lambda that processes flow-log-type data rather than CWLG type data: https://www.splunk.com/en_us/blog/partners/streamline-your-amazon-vpc-flow-logs-ingestion-to-splunk.html
# 3. Update this module to take a Firehose ARN instead of a CW destination ARN and remove/update the below code.
module "flow_logs_group" {
  source         = "../../monitoring/cloudwatch_log_group"
  log_group_name = "/aws/vpc/flow-logs/${var.vpc_name}"
  retention_days = 1 # Short retention because these logs are huge and all shipped to Splunk anyway
  tags           = local.tags
}


data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = [
      module.flow_logs_group.cloudwatch_log_group_arn,
      "${module.flow_logs_group.cloudwatch_log_group_arn}:*"
    ]
  }
}

module "flow_logs_role" {
  source = "../../iam/role"
  # Intentionally using role_name rather than role_name_prefix to prevent creation of duplicate-named VPCs in the same
  # account:
  role_name              = "${var.vpc_name}-flow-logs-write"
  tags                   = local.tags
  policy_json_documents  = { "${var.vpc_name}-flow-logs-write" = data.aws_iam_policy_document.policy.json }
  assume_role_principals = ["vpc-flow-logs.amazonaws.com"]
}

# VPC Flow Logs
resource "aws_flow_log" "this" {
  iam_role_arn    = module.flow_logs_role.role_arn
  log_destination = module.flow_logs_group.cloudwatch_log_group_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
  tags = merge(
    {
      Name = "${var.vpc_name}-flow-logs"
    },
    local.tags
  )
}

module "ship_logs_to_splunk" {
  source          = "../../monitoring/cloudwatch_log_shipping_source"
  destination_arn = var.log_shipping_destination_arn
  log_group_arns  = [module.flow_logs_group.cloudwatch_log_group_arn]
}