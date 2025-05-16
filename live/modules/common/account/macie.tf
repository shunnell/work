# Some Security Hub controls require Amazon Macie to be enabled. It's not adding a ton of value, but since it's cheap
# to run given the low volume of S3 assets in the account, we enable it as part of the baseline here. If that causes
# problems (unexpected costs etc) in the future, it can be disabled without significant impact.
resource "aws_macie2_account" "macie" {
  finding_publishing_frequency = "ONE_HOUR"
  status                       = "ENABLED"
}
