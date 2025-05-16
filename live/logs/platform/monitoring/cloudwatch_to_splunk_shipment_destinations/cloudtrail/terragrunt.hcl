include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "shipper_substrate" {
  config_path = "../shipper_failure_storage"
  mock_outputs = {
    failed_shipments_s3_bucket_arn             = "bad/arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
    failed_shipments_cloudwatch_log_group_name = "bad/name"
  }
}

locals {
  destination_name = "OrganizationWideCloudTrail"
  sourcetype       = "aws:cloudtrail"

  /*
      References:
      https://splunk.github.io/splunk-add-on-for-amazon-web-services/DataTypes/#push-based-amazon-kinesis-firehose-data-collection-sourcetypes
      https://splunk.github.io/splunk-add-on-for-amazon-web-services/DataTypes/

      aws:cloudtrail                      - AWS API call history from the AWS CloudTrail service, delivered as CloudWatch events. 
      aws:firehose:cloudwatchevents       - Data from CloudWatch. You can extract CloudTrail events embedded 
                                            within CloudWatch events with this sourcetype as well.
      aws:guardduty                       - GuardDuty events.
      aws:cloudwatchlogs:vpcflow          - VPC Flow Logs from CloudWatch. When ingesting CloudWatch logs, set the Lambda buffering 
                                            size to 1 MB.
      aws:cloudwatchlogs:transitgateway   - Collect Transit Gateway Flow Logs through HEC.
      aws:s3                              - Represents generic log data from your S3 buckets.
      aws:route53:resolver                - aws route53.
      aws:eventbridge                     - ecr, config, macie, inspector2, ssm, waf, access-analyzer, securityhub logs, codeartifact
  */

}

terraform {
  source = "${get_path_to_repo_root()}/../modules//monitoring/cloudwatch_log_shipping_destination"
}

inputs = {
  destination_name                           = local.destination_name
  log_sourcetype                             = local.sourcetype
  failed_shipments_s3_bucket_arn             = dependency.shipper_substrate.outputs.failed_shipments_s3_bucket_arn
  failed_shipments_cloudwatch_log_group_name = dependency.shipper_substrate.outputs.failed_shipments_cloudwatch_log_group_name
  log_sender_aws_organization_path           = read_terragrunt_config("${get_path_to_repo_root()}/management/account.hcl").locals.bespin_organization_root_id
}
