# https://repost.aws/knowledge-center/kinesis-firehose-cloudwatch-logs
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-trustpolicy.html
resource "aws_iam_policy" "write_to_firehose" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "firehose:ListDeliveryStreams",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "firehose:DescribeDeliveryStream",
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        # NB: "arn:aws:firehose:us-east-1:${var.destination_account}:*" was recommended by awsdocs, but given that
        # this policy permissions cross-account access, I opted for a narrower scope, which seems to work fine.
        Resource = aws_kinesis_firehose_delivery_stream.firehose_stream.arn
      }
    ]
  })
  tags = var.tags
}

# This is a weird role; it's not, as would usually be written, a role which allows the *destination* to write to
# firehose. Rather, this role is provided by the Logs::Destination resource to the remote writers using that destination,
# so that those remote writers can produce logs "on the destination's behalf". Because of this, the principal needs to
# be cross-account, and not the destination itself.
module "write_to_firehose_role" {
  source           = "../../iam/role"
  role_name_prefix = "C2F-${var.destination_name}" # CloudWatch to Firehose
  trust_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "logs.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "aws:SourceOrgID" = [var.log_sender_aws_organization_path]
          }
        }
      }
    ]
  })
  policy_arns = [aws_iam_policy.write_to_firehose.arn]
  tags        = var.tags
}


# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CrossAccountSubscriptions-Firehose-Account.html
resource "aws_cloudwatch_log_destination" "log_destination" {
  name       = "C2S-${var.destination_name}" # CloudWatch to Splunk
  role_arn   = module.write_to_firehose_role.role_arn
  target_arn = aws_kinesis_firehose_delivery_stream.firehose_stream.arn
}

resource "aws_cloudwatch_log_destination_policy" "destination_cross_account_policy" {
  destination_name = aws_cloudwatch_log_destination.log_destination.name
  force_update     = true
  access_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # TODO deny if self/loop
      {
        Effect = "Allow",
        Action = [
          "logs:PutSubscriptionFilter",
          "logs:PutAccountPolicy", # NB TODO some tutorials recommended this, why?
        ]
        Resource  = aws_cloudwatch_log_destination.log_destination.arn,
        Principal = "*"
        Condition = {
          # Use new-ish ability to pass destinations by org rather than account:
          # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CreateDestination.html
          # https://aws.amazon.com/about-aws/whats-new/2022/01/amazon-cloudwatch-logs-aws-organizations-subscriptions/
          StringEquals = {
            "aws:PrincipalOrgID" = [var.log_sender_aws_organization_path] # TODO magic string
          }
        }
      },
    ]
  })
}
