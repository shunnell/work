include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//monitoring//cloudwatch_log_metric_filter_alarms"
}

inputs = {
  metric_filter_alarms = {
    no_mfa_console = {
      metric_filter = {
        metric_name                 = "no-mfa-console-signin-metric"
        pattern                     = "{ ($.userIdentity.type = \"IAMUser\") && ($.userIdentity.sessionContext.attributes.mfaAuthenticated = \"false\") && ($.sessionCredentialFromConsole = \"true\") }"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "no-mfa-console-signin-alarm"
        alarm_description   = "Alarm for console sign-in without MFA"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    root_usage = {
      metric_filter = {
        metric_name                 = "root-usage-metric"
        pattern                     = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "root-usage-alarm"
        alarm_description   = "Alarm for AWS root account usage"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    iam_changes = {
      metric_filter = {
        metric_name                 = "iam-changes-metric"
        pattern                     = "{($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "iam-changes-alarm"
        alarm_description   = "Alarm for IAM policy changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    unauthorized_api = {
      metric_filter = {
        metric_name                 = "unauthorized-api-access"
        pattern                     = "{($.errorCode=*UnauthorizedOperation)||($.errorCode=AccessDenied*)&&($.sourceIPAddress!=delivery.logs.amazonaws.com)&&($.eventName!=HeadBucket)}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "unauthorized-api-access-alarm"
        alarm_description   = "Alarm for unauthorized API access"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    cloudtrail_changes = {
      metric_filter = {
        metric_name                 = "cloudtrail-changes"
        pattern                     = "{($.eventName=CreateTrail)||($.eventName=UpdateTrail)||($.eventName=DeleteTrail)||($.eventName=StartLogging)||($.eventName=StopLogging)}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "cloudtrail-changes-alarm"
        alarm_description   = "Alarm for CloudTrail changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    console_auth_failures = {
      metric_filter = {
        metric_name                 = "console-auth-failure"
        pattern                     = "{($.eventName=ConsoleLogin)&&($.errorMessage=\"Failed authentication\")}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "console-auth-failure-alarm"
        alarm_description   = "Alarm for Console auth failures"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    cmk_monitor = {
      metric_filter = {
        metric_name                 = "cmk-monitor"
        pattern                     = "{($.eventSource=kms.amazonaws.com)&&(($.eventName=DisableKey)||($.eventName=ScheduleKeyDeletion))}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "cmk-monitor-alarm"
        alarm_description   = "Alarm for CMK disabling or deletion"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    s3_policy_changes = {
      metric_filter = {
        metric_name                 = "s3-policy-changes"
        pattern                     = "{($.eventSource=s3.amazonaws.com)&&(($.eventName=PutBucketAcl)||($.eventName=PutBucketPolicy)||($.eventName=PutBucketCors)||($.eventName=PutBucketLifecycle)||($.eventName=PutBucketReplication)||($.eventName=DeleteBucketPolicy)||($.eventName=DeleteBucketCors)||($.eventName=DeleteBucketLifecycle)||($.eventName=DeleteBucketReplication))}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "s3-policy-changes-alarm"
        alarm_description   = "Alarm for S3 policy changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    aws_config_changes = {
      metric_filter = {
        metric_name                 = "aws-config-changes"
        pattern                     = "{($.eventSource=config.amazonaws.com)&&(($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel)||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder))}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "aws-config-changes-alarm"
        alarm_description   = "Alarm for AWS Config configuration changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    securitygroup_changes = {
      metric_filter = {
        metric_name                 = "securitygroup-changes"
        pattern                     = "{($.eventName=AuthorizeSecurityGroupIngress)||($.eventName=AuthorizeSecurityGroupEgress)||($.eventName=RevokeSecurityGroupIngress)||($.eventName=RevokeSecurityGroupEgress)||($.eventName=CreateSecurityGroup)||($.eventName=DeleteSecurityGroup)}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "securitygroup-changes-alarm"
        alarm_description   = "Alarm for AWS SecurityGroup changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    nacl_changes = {
      metric_filter = {
        metric_name                 = "nacl-changes"
        pattern                     = "{($.eventName=CreateNetworkAcl)||($.eventName=CreateNetworkAclEntry)||($.eventName=DeleteNetworkAcl)||($.eventName=DeleteNetworkAclEntry)||($.eventName=ReplaceNetworkAclEntry)||($.eventName=ReplaceNetworkAclAssociation)}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "nacl-changes-alarm"
        alarm_description   = "Alarm for NACL changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    network_gateway_changes = {
      metric_filter = {
        metric_name                 = "network-gateway-changes"
        pattern                     = "{($.eventName=CreateCustomerGateway)||($.eventName=DeleteCustomerGateway)||($.eventName=AttachInternetGateway)||($.eventName=CreateInternetGateway)||($.eventName=DeleteInternetGateway)||($.eventName=DetachInternetGateway)}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "network-gateway-changes-alarm"
        alarm_description   = "Alarm for Network Gateway changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    route_table_changes = {
      metric_filter = {
        metric_name                 = "route-table-changes"
        pattern                     = "{($.eventSource=ec2.amazonaws.com)&&($.eventName=CreateRoute)||($.eventName=CreateRouteTable)||($.eventName=ReplaceRoute)||($.eventName=ReplaceRouteTableAssociation)||($.eventName=DeleteRouteTable)||($.eventName=DeleteRoute)||($.eventName=DisassociateRouteTable)}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "route-table-changes-alarm"
        alarm_description   = "Alarm for Route Table changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    vpc_changes = {
      metric_filter = {
        metric_name                 = "vpc-changes"
        pattern                     = "{($.eventName=CreateVpc)||($.eventName=DeleteVpc)||($.eventName=ModifyVpcAttribute)||($.eventName=AcceptVpcPeeringConnection)||($.eventName=CreateVpcPeeringConnection)||($.eventName=DeleteVpcPeeringConnection)||($.eventName=RejectVpcPeeringConnection)||($.eventName=AttachClassicLinkVpc)||($.eventName=DetachClassicLinkVpc)||($.eventName=DisableVpcClassicLink)||($.eventName=EnableVpcClassicLink)}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "vpc-changes-alarm"
        alarm_description   = "Alarm for VPC changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    },
    organization_changes = {
      metric_filter = {
        metric_name                 = "organization-changes"
        pattern                     = "{($.eventSource=organizations.amazonaws.com)&&(($.eventName=AcceptHandshake)||($.eventName=AttachPolicy)||($.eventName=CreateAccount)||($.eventName=CreateOrganizationalUnit)||($.eventName=CreatePolicy)||($.eventName=DeclineHandshake)||($.eventName=DeleteOrganization)||($.eventName=DeleteOrganizationalUnit)||($.eventName=DeletePolicy)||($.eventName=DetachPolicy)||($.eventName=DisablePolicyType)||($.eventName=EnablePolicyType)||($.eventName=InviteAccountToOrganization)||($.eventName=LeaveOrganization)||($.eventName=MoveAccount)||($.eventName=RemoveAccountFromOrganization)||($.eventName=UpdatePolicy)||($.eventName=UpdateOrganizationalUnit))}"
        log_group_name              = "aws-controltower/CloudTrailLogs"
        namespace                   = "Security_checks"
        metric_transformation_value = 1
        default_value               = null
      }
      alarm = {
        alarm_name          = "organization-changes-alarm"
        alarm_description   = "Alarm for AWS Organization changes"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
        alarm_actions       = ["arn:aws:sns:us-east-1:590183957203:security-notifications"]
      }
    }
  }
}