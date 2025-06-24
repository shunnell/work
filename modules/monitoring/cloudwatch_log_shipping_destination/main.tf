data "aws_kms_key" "aws_s3" {
  key_id = "alias/aws/s3"
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  name        = "CloudCityLogsToSplunk-${var.destination_name}"
  destination = "splunk"
  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  splunk_configuration {
    hec_endpoint               = var.splunk_uri
    hec_token                  = var.splunk_hec_token
    hec_acknowledgment_timeout = var.splunk_acknowledgement_timeout
    buffering_interval         = var.shipment_buffering_time
    retry_duration             = var.shipment_retry_duration
    # hec_endpoint_type values: "Raw" and "Event".
    # splunk HEC had trouble identifying log types with Raw
    # better identification with Events.
    hec_endpoint_type = "Event"
    s3_backup_mode    = "FailedEventsOnly"

    processing_configuration {
      enabled = "true"
      # Ref:
      # https://docs.aws.amazon.com/firehose/latest/APIReference/API_Processor.html
      # https://docs.aws.amazon.com/firehose/latest/APIReference/API_ProcessorParameter.html
      # Processors can be one of: Can be: RecordDeAggregation | Decompression | CloudWatchLogProcessing | Lambda | MetadataExtraction | AppendDelimiterToRecord
      # RecordDeAggregation is only allowed for s3 destinations, not splunk.
      # Decompression requires a Lambda,  TODO
      # CloudWatchLogProcessing requires Decompression
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
        parameters {
          parameter_name  = "RoleArn"
          parameter_value = module.firehose_role.role_arn #TODO this is a terraform bug?
        }
      }
      # processors {
      #   type = "Decompression"
      # }
      # processors {
      #   type = "CloudWatchLogProcessing"
      #
      #   parameters {
      #     parameter_name  = "DataMessageExtraction"
      #     parameter_value = true
      #   }
      # }
    }

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = var.failed_shipments_cloudwatch_log_group_name
      log_stream_name = aws_cloudwatch_log_stream.firehose_shipment_failure_log_stream.name
    }
    s3_configuration {
      # NB: This role_arn is the control point for the role used by the *entire splunk shipping system*, not (as it
      # would seem to indicate) the role used for writing to S3. It's written in this block due to what I believe is a
      # Terraform AWS provider defect.
      role_arn   = module.firehose_role.role_arn
      bucket_arn = var.failed_shipments_s3_bucket_arn
      # These, too, seem to correspond to firehose buffering/shipment as a whole despite their being written in an S3-
      # -specific block. Buffering time is duplicated with a top-level setting in the outer block since both fields
      # are required. TODO this may be something we can clean up.
      buffering_size     = var.shipment_buffering_size
      buffering_interval = var.shipment_buffering_time
      compression_format = "GZIP"
      kms_key_arn        = data.aws_kms_key.aws_s3.arn
    }
  }
  tags = var.tags
}

# Note that the permissions that allow firehose to write to these are in iam_firehose_processing_and_output.tf.
resource "aws_cloudwatch_log_stream" "firehose_shipment_failure_log_stream" {
  name           = "${var.failed_shipments_cloudwatch_log_group_name}/${var.destination_name}"
  log_group_name = var.failed_shipments_cloudwatch_log_group_name
}
