data "aws_iam_policy_document" "_ec2_restrictions" {
  statement {
    sid    = "DenyPublicIPInstanceCreation"
    effect = "Deny"
    actions = [
      "ec2:RunInstances"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      values   = ["true"]
      variable = "ec2:AssociatePublicIpAddress"
    }
  }
  statement {
    sid    = "DenyPublicIPModification"
    effect = "Deny"
    actions = [
      "ec2:ModifyInstanceAttribute",
      "ec2:AssociateAddress",
      "ec2:AttachNetworkInterface",
    ]
    resources = ["*:*:ec2:*:*:instance/*", "*:*:ec2:*:*:network-interface/*"]
    condition {
      test     = "BoolIfExists"
      values   = ["true"]
      variable = "ec2:AssociatePublicIpAddress"
    }
  }
  statement {
    sid    = "DenyEIPAllocation"
    effect = "Deny"
    actions = [
      "ec2:AllocateAddress"
    ]
    resources = ["*:*:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["vpc"]
      variable = "ec2:Domain"
    }
  }
}

# EC2 restrictions must permit a couple of uniquely-positioned principals to go "around" them:
module "ec2_restrictions" {
  source         = "../modified_policy_document"
  require_effect = "deny"
  policies       = [data.aws_iam_policy_document._ec2_restrictions.json]
  add_conditions_to_all_stanzas = [{
    test     = "ArnNotLike"
    variable = "aws:PrincipalARN"
    values = [
      # AWSAdministratorAccess is never explicitly granted via SSO, but it is the default group/PS mapping present when
      # a brand new AWS Account is created via AWS Control Tower. If Control Tower for some reason fails to configiure
      # the account (or if we need to do things in an account before we assign Cloud_City_Admin users to it in SSO), it
      # is convenient to also allow AWSAdministratorAccess to do stuff in the account to fix Control Tower breakage.
      "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess*",
      # When Control Tower provisions an account for the first time, it needs to manipulate sensitive networking (it
      # creates and deletes VPCs, modifies account default networking settings, etc.). We don't love it when Control
      # Tower makes changes to accounts after they're up and managed by IaC (and over time we will reduce the number of
      # situations where it does that), but we do need it when an account is first bootstrapped, so it is omitted from
      # the restrictions placed below.
      "arn:aws:iam::*:role/AWSControlTowerExecution",
    ]
  }]
}

data "aws_iam_policy_document" "tenant_ec2_permissions" {
  statement {
    sid = "AllowEC2Read"
    actions = [
      "ec2:Describe*",
      "ec2:List*",
      "ec2:Get*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowEC2Broadly"
    effect = "Allow"
    actions = [
      "ec2:*",
    ]
    resources = [
      "*:*:ec2:*:*:declarative-policies-report*",
      "*:*:ec2:*:*:elastic-gpu*",
      "*:*:ec2:*:*:elastic-inference*",
      "*:*:ec2:*:*:export-image-task*",
      "*:*:ec2:*:*:export-instance-task*",
      "*:*:ec2:*:*:fleet*",
      "*:*:ec2:*:*:group*",
      "*:*:ec2:*:*:image*",
      "*:*:ec2:*:*:import-image-task*",
      "*:*:ec2:*:*:import-snapshot-task*",
      "*:*:ec2:*:*:instance*",
      "*:*:ec2:*:*:instance-event-window*",
      "*:*:ec2:*:*:key-pair*",
      "*:*:ec2:*:*:launch-template*",
      "*:*:ec2:*:*:license-configuration*",
      "*:*:ec2:*:*:network-interface*",
      "*:*:ec2:*:*:placement-group*",
      "*:*:ec2:*:*:replace-root-volume-task*",
      "*:*:ec2:*:*:reserved-instances*",
      "*:*:ec2:*:*:role*",
      "*:*:ec2:*:*:snapshot*",
      "*:*:ec2:*:*:spot-fleet-request*",
      "*:*:ec2:*:*:spot-instances-request*",
      "*:*:ec2:*:*:volume*",
    ]
  }
  statement {
    sid    = "AllowEC2Tagging"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "LimitedEC2Networking"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroup*",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:ModifySecurityGroupRules",
      "ec2:RevokeSecurityGroup*",
      "ec2:UpdateSecurityGroupRuleDescriptions*",
      "ec2:RunInstances",
      "ec2:CreateNetworkInterface"
    ]
    resources = [
      "*:*:ec2:*:*:security-group*",
      # Some security group and NIC actions are on VPC-type resources rather than security-group or sgr-type resources.
      "*:*:ec2:*:*:vpc*"
    ]
  }
}