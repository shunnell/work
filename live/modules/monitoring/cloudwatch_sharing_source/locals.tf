# Dummy provider requirement block to pull the arn_parse function's namespace into scope:
# https://github.com/hashicorp/terraform/issues/35753
terraform {
  required_providers {
    aws = {}
  }
}

data "aws_caller_identity" "current" {}

locals {
  sink_account = var.sink_id == null ? null : provider::aws::arn_parse(var.sink_id).account_id
}
