resource "aws_organizations_policy" "restrict_cloudshell" {
  name        = "RestrictCloudShellAccess"
  description = "Deny cloudshell access"
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "cloudshell:CreateEnvironment",
          "cloudshell:StartEnvironment",
          "cloudshell:CreateSession",
          "cloudshell:StopEnvironment",
          "cloudshell:DeleteEnvironment",
          "cloudshell:GetEnvironmentStatus",
          "cloudshell:UpdateEnvironment",
          "cloudshell:GetEnvironmentSettings",
          "cloudshell:PutCredentials",
          "cloudshell:ListFiles",
          "cloudshell:GetFileDownloadUrls",
          "cloudshell:GetFileUploadUrls"
        ]
        Resource = "*"
      }
    ]
  })
  tags = {
    purpose = "Deny cloudshell access"
  }
}
# Attach SCP to Root or OU
resource "aws_organizations_policy_attachment" "attach_to_root" {
  policy_id = aws_organizations_policy.restrict_cloudshell.id
  target_id = var.organization_root_id # Replace with Root ID or OU ID
}
