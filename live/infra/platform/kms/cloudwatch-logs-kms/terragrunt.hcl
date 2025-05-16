include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//kms/key/"
}

inputs = {
  description = "KMS key for encrypting cloudwatch logs"
  alias       = "cloud-city/cloudwatch-logs"
  policy_stanzas = {
    "Allow CloudWatch Logs to use the key" = {
      principals = {
        "Service" = ["logs.us-east-1.amazonaws.com"]
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]
      conditions = [
        {
          test     = "ArnLike"
          variable = "kms:EncryptionContext:aws:logs:arn"
          values   = ["arn:aws:logs:us-east-1:381492150796:*"]
        }
      ]
    }
  }

}
