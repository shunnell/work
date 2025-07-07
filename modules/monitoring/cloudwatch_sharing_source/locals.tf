data "aws_caller_identity" "current" {}

locals {
  sink_account = var.sink_id == null ? null : regex("^arn:aws:oam:\\S*:(\\d+):sink/\\S+$", var.sink_id)[0]
}
