module "monitoring_account_can_list_accounts" {
  source      = "../../iam/policy"
  policy_name = "CloudWatch-CrossAccountListAccountsPolicy"
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "organizations:ListAccounts",
          "organizations:ListAccountsForParent"
        ],
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

module "orgwide_sharing_role" {
  source = "../../iam/role"
  # Magic string name checked by AWS, see docs:
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Cross-Account-Cross-Region.html
  role_name              = "CloudWatch-CrossAccountListAccountsRole"
  assume_role_principals = ["arn:aws:iam::${var.monitoring_account_id}:root"]
  policy_arns            = [module.monitoring_account_can_list_accounts.policy_arn]
}
