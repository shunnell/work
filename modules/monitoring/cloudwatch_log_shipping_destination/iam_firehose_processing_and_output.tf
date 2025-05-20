resource "aws_iam_policy" "firehose_execution_and_processing" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          var.failed_shipments_s3_bucket_arn,
          "${var.failed_shipments_s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents"
        ],
        Resource = aws_cloudwatch_log_stream.firehose_shipment_failure_log_stream.arn
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:GetFunctionConfiguration",
          "lambda:InvokeFunction"
        ]
        Resource = [
          aws_lambda_function.lambda_processor.arn,
          "${aws_lambda_function.lambda_processor.arn}:*"
        ]
      },
    ]
  })
  tags = var.tags
}

module "firehose_role" {
  source                 = "../../iam/role"
  role_name_prefix       = "F2S-${var.destination_name}" # Firehose to Splunk
  assume_role_principals = ["firehose.amazonaws.com"]
  policy_arns            = [aws_iam_policy.firehose_execution_and_processing.arn]
  tags                   = var.tags
}
