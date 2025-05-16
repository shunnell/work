variable "scp_excluded_principals" {
  type        = list(string)
  description = "ARN patterns for principals (roles) that should be excluded from the SCP's deny statements"
  default = [
    # Exclude humans in the Cloud_City_Admin group.
    "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_Cloud_City_Admin*",
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
    # Exclude terragrunt
    "arn:aws:iam::*:role/terragrunter"
  ]
}

data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_unit" "sandbox" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
  name      = "Sandbox"
}

resource "aws_organizations_policy" "restrict_iam_users" {
  name        = "RestrictIAMUsers"
  description = "Deny New IAM User Creation"
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action : "iam:CreateUser",
        Resource = "*"
        Condition = {
          ArnNotLike = {
            "aws:PrincipalARN" : var.scp_excluded_principals
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "attach_policy_sandbox" {
  policy_id = aws_organizations_policy.restrict_iam_users.id
  target_id = data.aws_organizations_organizational_unit.sandbox.id
}