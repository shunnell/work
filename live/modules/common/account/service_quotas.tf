locals {
  quotas = {
    # Many of these are requested "just in case" accounts/the platform need them as a baseline. A few are quotas that
    # we've actually run into while managing IaC.
    # In general, a quota should only be added here if:
    # 1. Issues have occurred that hit it, and
    # 2. Abuse of the increased quota isn't likely to cause cost overruns (e.g. don't increase lambda concurrency limits
    #    everywhere just because one person needs it; runaway Lambda is a very expensive bug).
    "vpc.Inbound or outbound rules per security group" = 100
    "vpc.Gateway VPC endpoints per Region"             = 100
    "vpc.Interface VPC endpoints per VPC"              = 100
    "vpc.NAT gateways per Availability Zone"           = 100
    "vpc.Network interfaces per Region"                = 10000
    "vpc.Routes per route table"                       = 100
    "vpc.Rules per network ACL"                        = 40 # Maximum allowed by AWS
    "vpc.Security groups per network interface"        = 10
    # Negative numbers still set positive quotas, just in a different way. See comment on
    # 'quotas_requiring_support_approval' below.
    "vpc.VPCs per Region"                       = -16
    "iam.Customer managed policies per account" = 3000
    "iam.Roles per account"                     = 3000
    "iam.Managed policies per role"             = 20   # Maximum allowed by AWS
    "iam.Role trust policy length"              = 4096 # Maximum allowed by AWS
    # Note that the SSO quotas "Number of permission sets allowed in IAM Identity Center" and "Number of permission sets
    # allowed in IAM Identity Center" were requested manually for only the organizations master account and should not
    # be added here unless the platform's usage of SSO changes significantly.
  }
}

# NB: if we ever run TF in other regions, all quotas can only be manipulated from USE1 as a hard AWS requirement. If
# multiregion becomes a thing, a dedicated USE1 provider will need to be around for use when running IaC pointed at
# non-USE1 regions, like the below resources. That's not a common need so instances of this situation should be rare.
data "aws_servicequotas_service_quota" "quotas_by_name" {
  for_each     = local.quotas
  service_code = split(".", each.key)[0]
  quota_name   = split(".", each.key)[1]
}

resource "aws_servicequotas_service_quota" "quotas_requiring_support_approval" {
  for_each     = { for k, v in local.quotas : k => v if v < 0 }
  quota_code   = data.aws_servicequotas_service_quota.quotas_by_name[each.key].quota_code
  service_code = split(".", each.key)[0]
  value        = abs(each.value) # Quotas needing the special AWS support review are marked with negative numbers.
  lifecycle {
    # IMPORTANT NOTE: When quotas are created, many of them go into internal ticket review with AWS support. While that
    # is waiting for approval, terraform tries to re-create the quotas and fails with "a request is already open for
    # this quota". To avoid that, we ignore changes to the value, trusting the request to be sent when the terraform
    # resource is first created.
    # HOWEVER, that means that changes to the values after creation will require destroying (commenting out in the
    # local list above), applying, then uncommenting and re-applying tbe updated quota increase request. There doesn't
    # seem to be a cleaner way to automate that, so some manual action may be needed when changing previously-increased
    # values to different number.
    ignore_changes = [value]
  }
}

resource "aws_servicequotas_service_quota" "quotas" {
  for_each     = { for k, v in local.quotas : k => v if v >= 0 }
  quota_code   = data.aws_servicequotas_service_quota.quotas_by_name[each.key].quota_code
  service_code = split(".", each.key)[0]
  value        = each.value
}

output "quotas" {
  value = { for quota, value in local.quotas : quota => data.aws_servicequotas_service_quota.quotas_by_name[quota].quota_code }
}
