# Set up a "target" that other accounts' CloudWatch resources can be shared with via OAM.
# Multiple/granular targets is only necessary if we need fine-grained access control on shared CloudWatch stuff. Since
# sharing is just done with "ship it all to Splunk" in mind, we don't need that, so can use only one sink.


# Only one constant input variable = no need for separate inputs.tf. If more inputs are ever added, split this out into
# a new file.
variable "aws_organization_id" {
  description = "ID of AWS Organization"
  type        = string
}

# The below terraform does exactly what the official AWS cloudwatch log centralization (UCAS) docs suggest:
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Unified-Cross-Account-Setup.html#Unified-Cross-Account-Setup-TemplateOrURL
# Where those docs suggest exporting a CloudFormation template from a logging destination account and running that
# template in the organizations master account, the template exported contains exactly the invocations that the below
# Terraform creates; you can test-export a CF template from the logging account in the UI to validate this; the template
# is only a few lines.


# For details/examples, of this in Terraform, see https://github.com/aws-samples/cloudwatch-obervability-access-manager-terraform
# or https://gds.blog.gov.uk/2023/07/26/enabling-aws-cross-account-monitoring-using-terraform/.
# We're not using the first link's module because it's several hundred lines of linter/wrapping/doc around exactly three
# resource invocations--the same three we perform. Third party modules are great when they save work; that one does not.

resource "aws_oam_sink" "cloudwatch_sink" {
  name = "observabilitySink"
}

output "logging_account_oam_sink_id" {
  description = "ID for Cloudwatch Sink"
  value       = aws_oam_sink.cloudwatch_sink.id
}

# This policy is derived from the one created by the AWS UCAS docs linked above; its default policy looks exactly like
# this, but for more ResourceTypes (we only needed LogGroups at the time of this writing).
resource "aws_oam_sink_policy" "central_logging_sink_policy" {
  sink_identifier = aws_oam_sink.cloudwatch_sink.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = ["oam:CreateLink", "oam:UpdateLink"]
        Effect    = "Allow"
        Resource  = "*"
        Principal = "*"
        Condition = {
          "ForAllValues:StringEquals" = {
            # If we want to share more CloudWatch data types with the logging account (either for shipment somewhere,
            # or to use that account for centralized cross-BESPIN monitoring by users), they can be added here.
            "oam:ResourceTypes" = ["AWS::Logs::LogGroup", "AWS::CloudWatch::Metric"]
          }
          "ForAnyValue:StringEquals" = {
            "aws:PrincipalOrgID" = var.aws_organization_id
          }
        }
      }
    ]
  })
}

