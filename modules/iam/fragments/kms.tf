data "aws_iam_policy_document" "kms_restrictions" {
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
    # Two types of principals can decrypt using KMS keys (though principals can't be specified here since this fragment
    # is to be used in an SCP):
    # 1. AWS services decrypting on behalf of a user, for which the kms:ViaService will be set.
    # 2. The ec2-infrastructure role when using encrypted EBS volumes on an instance:
    #    https://aws.amazon.com/blogs/security/how-to-use-policies-to-restrict-where-ec2-instance-credentials-can-be-used-from/
    #    https://docs.aws.amazon.com/kms/latest/developerguide/ct-ec2two.html
    # This statement then boils down to saying "if ViaService is null AND if the principal isn't EC2 doing EBS stuff,
    # deny decryption.
    condition {
      test     = "Null"
      values   = [true]
      variable = "kms:ViaService"
    }
    condition {
      test     = "ArnNotLike"
      values   = ["arn:aws:iam::*:role/aws:ec2-infrastructure"]
      variable = "aws:PrincipalArn"
    }
  }
}