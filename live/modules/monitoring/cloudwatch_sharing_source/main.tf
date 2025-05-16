
resource "aws_oam_link" "link" {
  # Disable if sink is not set
  count           = var.sink_id == null ? 0 : 1
  label_template  = "$AccountName"
  resource_types  = var.shared_resource_types
  sink_identifier = var.sink_id
  lifecycle {
    # Creating a loop (source = target) is bad: even AWS's official CloudFormation prevents that at the top level; we
    # should too. Not validating in the variable since the validation depends on a data variable.
    precondition {
      condition     = local.sink_account != data.aws_caller_identity.current.account_id
      error_message = "Cannot set up an account as a cloudwatch sharing source of itself (account ID ${local.sink_account})"
    }
  }
  tags = var.tags
}


# Set up the role needed to manage cross-account data sharing throughout the organization; this enables some UI browsability
# for CloudWatch entities in the monitoring account.
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Cross-Account-Cross-Region.html
module "cacr_role" {
  count  = var.sink_id == null ? 0 : 1
  source = "../../iam/role"
  # NB: This magic string name is significant inside AWS and must not be changed. Nobody accused CACR of being elegant.
  role_name              = "CloudWatch-CrossAccountSharingRole"
  assume_role_principals = ["arn:aws:iam::${local.sink_account}:root"]
  policy_arns            = []
  tags                   = var.tags
}
