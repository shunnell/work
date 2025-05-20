module "s3_bucket" {
  source               = "../../s3"
  globally_unique_name = "cloudcity-splunk-shipper-failures"
  name_prefix          = null
}

module "log_group" {
  source         = "../cloudwatch_log_group"
  log_group_name = "cloudcity-splunk-shipper-failures"
}
