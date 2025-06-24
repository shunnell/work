# https://fullstackdojo.medium.com/streamlining-real-time-data-processing-with-aws-kinesis-lambda-and-terraform-36de21899d51
module "lambda_role" {
  source                 = "../../iam/role"
  role_name_prefix       = "FSP-${var.destination_name}" # Firehose Splunk Lambda
  assume_role_principals = ["lambda.amazonaws.com"]
  policy_arns            = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  tags                   = var.tags
}

# From https://github.com/felipefrizzo/terraform-aws-kinesis-firehose
data "archive_file" "transformer_lambda_script" {
  type = "zip"
  # When ./ is used instead of path.module below, failures occur when this module is not the entry point, and is included
  # from other modules:
  source_file = "${path.module}/log_transformation.py"
  output_path = "${path.module}/log_transformation.zip"
}

# See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#cloudwatch-logging-and-permissions
# This can be done automatically by Lambda, but doing it explicitly facilitates cleanup on TF deletion.
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/splunk-${var.destination_name}" # TODO dedup
  retention_in_days = 90
  tags              = var.tags
}

resource "aws_lambda_function" "lambda_processor" {
  function_name    = "splunk-${var.destination_name}"
  handler          = "log_transformation.lambda_handler"
  role             = module.lambda_role.role_arn
  runtime          = "python3.12"
  timeout          = 60 # Recommended by AWS; scary modal in the UI if you set a value lower
  filename         = data.archive_file.transformer_lambda_script.output_path
  source_code_hash = data.archive_file.transformer_lambda_script.output_base64sha256
  environment {
    variables = {
      SOURCE_TYPE              = var.log_sourcetype
      CLOUD_CITY_ACCT_MAPPINGS = jsonencode(var.account_list_mapping)
    }
  }
  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
  ]
  tags = var.tags
}
