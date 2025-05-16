data "aws_iam_policy_document" "kms_decryption" {
  # Security Hub complains if broad kms:Decrypt permissions are given to all resources.
  # Ref: https://docs.aws.amazon.com/secretsmanager/latest/userguide/security-encryption.html#security-encryption-authz
  # Human users shouldn't have to manually decrypt data with KMS in any cases; if more use-cases appear then this policy
  # can be updated to reflect new needs. Instead, humans should request that an AWS service decrypt on their behalf.
  # NB: this still generates the KMS.1 Security Hub finding in many cases! Details as to why we believe those findings
  # can be discounted as false are available here:
  statement {
    sid       = "DenyKMSDecryptUnlessOnBehalfOfAWS"
    effect    = "Deny"
    actions   = ["kms:Decrypt", "kms:ReEncrypt*"]
    resources = ["*"]
    condition {
      test     = "Null"
      values   = [true]
      variable = "kms:ViaService"
    }
  }
}

output "kms_decrypt_restrictions" {
  value = data.aws_iam_policy_document.kms_decryption
}