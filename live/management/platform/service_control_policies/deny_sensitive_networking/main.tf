variable "scp_excluded_principals" {
  type        = list(string)
  description = "ARN patterns for principals (roles) that should be excluded from the SCP's deny statements"
  default = [
    # Exclude humans in the Cloud_City_Admin group.
    "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_Cloud_City_Admin*",
    # AWSAdministratorAccess is never explicitly granted via SSO, but it is the default group/PS mapping present when
    # a brand new AWS Account is created via AWS Control Tower. If Control Tower for some reason fails to configiure
    # the account (or if we need to do things in an account before we assign Cloud_City_Admin users to it in SSO), it
    # is convenient to also allow AWSAdministratorAccess to do stuff in the account to fix Control Tower breakage.
    "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess*",
    # When Control Tower provisions an account for the first time, it needs to manipulate sensitive networking (it
    # creates and deletes VPCs, modifies account default networking settings, etc.). We don't love it when Control
    # Tower makes changes to accounts after they're up and managed by IaC (and over time we will reduce the number of
    # situations where it does that), but we do need it when an account is first bootstrapped, so it is omitted from
    # the restrictions placed below.
    "arn:aws:iam::*:role/AWSControlTowerExecution",
    # Exclude terragrunt
    "arn:aws:iam::*:role/terragrunter"
  ]
}


data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_unit" "production" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
  name      = "Production"
}

data "aws_organizations_organizational_unit" "sandbox" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
  name      = "Sandbox"
}

resource "aws_organizations_policy" "deny_sensitive_networking" {
  name        = "DenySensitiveNetworking"
  description = "Restrict any operations on sensitive network to Admin-only"
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Deny direct sensitive networking modifications
      {
        Effect = "Deny",
        NotAction = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*",
          "ec2:Search*",
          "ec2:Run*",
          # Allow creating security groups (this action touches VPCs)
          "ec2:AuthorizeSecurityGroup*",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:ModifySecurityGroupRules",
          "ec2:RevokeSecurityGroup*",
          "ec2:UpdateSecurityGroupRuleDescriptions*",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          # Allow a set of (hopefully) non-risky deletion/detachment actions so that tenants can self-serve some cleanup
          # tasks on "grandfathered in" infrastructure without requiring Platform team assistance:
          "ec2:DetachInternetGateway",
          "ec2:DetachNetworkInterface",
          "ec2:DeleteCarrierGateway",
          "ec2:DeleteCustomerGateway",
          "ec2:DeleteDhcpOptions",
          "ec2:DeleteEgressOnlyInternetGateway",
          "ec2:DeleteInstanceConnectEndpoint",
          "ec2:DeleteInstanceEventWindow",
          "ec2:DeleteInternetGateway",
          "ec2:DeleteLocalGatewayRouteTable",
          "ec2:DeleteLocalGatewayRouteTablePermission",
          "ec2:DeleteLocalGatewayRouteTableVirtualInterfaceGroupAssociation",
          "ec2:DeleteLocalGatewayRouteTableVpcAssociation",
          "ec2:DeleteNatGateway",
          "ec2:DeleteNetworkInterface",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:DeletePlacementGroup",
          "ec2:DeletePublicIpv4Pool",
          "ec2:DeleteSpotDatafeedSubscription",
          "ec2:DeleteSubnet",
          "ec2:DeleteSubnetCidrReservation",
          "ec2:DisassociateSubnetCidrBlock",
          "ec2:DeleteTags",
          "ec2:DeleteVpcBlockPublicAccessExclusion",
          "ec2:DeleteVpc",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcEndpointServices",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcs",
          "ec2:ModifyVpcEndpoint",
          "iam:GetRole",
          "pipes:DescribePipe",
        ],
        Resource = [
          "arn:aws:ec2:*:*:carrier-gateway*",
          "arn:aws:ec2:*:*:client-vpn-endpoint*",
          "arn:aws:ec2:*:*:coip-pool*",
          "arn:aws:ec2:*:*:customer-gateway*",
          "arn:aws:ec2:*:*:dhcp-options*",
          "arn:aws:ec2:*:*:egress-only-internet-gateway*",
          "arn:aws:ec2:*:*:elastic-ip*",
          "arn:aws:ec2:*:*:instance-connect-endpoint*",
          "arn:aws:ec2:*:*:internet-gateway*",
          "arn:aws:ec2:*:*:ipam*",
          "arn:aws:ec2:*:*:ipv*",
          "arn:aws:ec2:*:*:local-gateway*",
          "arn:aws:ec2:*:*:natgateway*",
          "arn:aws:ec2:*:*:network-acl*",
          "arn:aws:ec2:*:*:prefix-list*",
          "arn:aws:ec2:*:*:route-table*",
          "arn:aws:ec2:*:*:subnet-cidr-reservation*",
          "arn:aws:ec2:*:*:traffic-mirror*",
          "arn:aws:ec2:*:*:transit-gateway*",
          "arn:aws:ec2:*:*:vpc*",
          "arn:aws:ec2:*:*:vpn*",
        ],
        Condition = {
          ArnNotLike = {
            "aws:PrincipalARN" : var.scp_excluded_principals
          }
        }
      },

      # Deny sharing of resources
      {
        Effect = "Deny",
        Action = [
          "ram:CreateResourceShare",
          "ram:UpdateResourceShare"
        ],
        Resource = "*",
        Condition = {
          ArnNotLike = {
            "aws:PrincipalARN" : var.scp_excluded_principals
          }
        }
      },

      # Deny Non-Private API Gateways

      {
        Sid    = "DenyNonPrivateAPIGatewayCreation"
        Effect = "Deny"
        Action = [
          "apigateway:CreateRestApi",
          "apigateway:UpdateRestApi"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            # Must be PRIVATE
            "apigateway:EndpointConfigurationTypes" = "PRIVATE"
          }
          ArnNotLike = {
            "aws:PrincipalARN" = var.scp_excluded_principals
          }
        }
      },

      # Deny Public IPs to all resources (except for the ones in the excluded principals list)
      # This is a blanket deny for all resources, but it is scoped to the actions that would assign public IPs to resources.
      {
        Sid    = "DenyPublicIPAssociation",
        Effect = "Deny",
        Action = [
          "ec2:AssociateAddress",
          "ec2:AllocateAddress",
          "ec2:RunInstances"
        ],
        Resource = [
          "arn:aws:ec2:*:*:instance/*",
          "arn:aws:ec2:*:*:elastic-ip/*",
          "arn:aws:ec2:*:*:network-interface/*"
        ],
        Condition = {
          "Bool" = {
            "ec2:AssociatePublicIpAddress" = "true"
          },
          "ArnNotLike" = {
            "aws:PrincipalARN" : var.scp_excluded_principals
          }
        }
      },
      # Deny creation of internet-facing load balancers
      {
        Sid      = "DenyInternetFacingLBs",
        Effect   = "Deny",
        Action   = "elasticloadbalancing:CreateLoadBalancer",
        Resource = "*",
        Condition = {
          StringEquals = {
            "elasticloadbalancing:Scheme" = "internet-facing"
          },
          ArnNotLike = {
            "aws:PrincipalARN" : var.scp_excluded_principals
          }
        }
      }
    ]
  })
  tags = {
    purpose = "Restrict any operations on sensitive network to Admin-only"
  }
}

resource "aws_organizations_policy_attachment" "attach_policy_production" {
  policy_id = aws_organizations_policy.deny_sensitive_networking.id
  target_id = data.aws_organizations_organizational_unit.production.id
}

resource "aws_organizations_policy_attachment" "attach_policy_sandbox" {
  policy_id = aws_organizations_policy.deny_sensitive_networking.id
  target_id = data.aws_organizations_organizational_unit.sandbox.id
}
