from types_boto3_iam import IAMClient
from bespin_tools.lib.testing.iam_simulation import ContextEntry, simulate_identity_policy
from types_boto3_iam.type_defs import RoleTypeDef

# NOTE:
#   * All of the ARNs in the resource lists are FAKE
#   * the {account_id} isn't replaced, because it's assumed not to matter
#   * Service Control Policies and Resource policies aren't accounted for

def test_allow_sandbox_dev_manage_eks_oidc_provider(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "iam:CreateOpenIDConnectProvider": "allowed",
            "iam:DeleteOpenIDConnectProvider": "allowed"
        },
        resources=[
            "arn:aws:iam::{account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/766C1E379BF09B7F41106E326FCB6377",
            "arn:aws:iam::{account_id}:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/766C1E379BF09B7F41106E326FCB6377"
        ]
    )

def test_deny_sandbox_dev_create_other_oidc_provider(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "iam:CreateOpenIDConnectProvider": "implicitDeny",
            "iam:DeleteOpenIDConnectProvider": "implicitDeny"
        },
        resources=[
            "arn:aws:iam::{account_id}:oidc-provider/server.example.com"
        ]
    )

def test_allow_manage_service_linked_role(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "iam:CreateServiceLinkedRole": "allowed",
            "iam:DeleteServiceLinkedRole": "allowed"
        },
        resources=[
            "arn:aws:iam::{account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
        ],
        context_entries=[
            ContextEntry(
                ContextKeyName="iam:AWSServiceName",
                ContextKeyValues=["rds.amazonaws.com"],
                ContextKeyType="string"
            )
        ]
    )

def test_allow_create_security_groups(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "ec2:CreateSecurityGroup": "allowed",
            "ec2:DeleteSecurityGroup": "allowed"
        },
        resources=[
            "arn:aws:ec2:us-east-1:{account_id}:security-group/sg-123456789",
            "arn:aws:ec2:us-east-1:{account_id}:vpc/vpc-123456789"

        ]
    )

def test_deny_create_vpc(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "ec2:CreateVPC": "implicitDeny",
            "ec2:DeleteVPC": "implicitDeny",
        },
        resources=[
            "arn:aws:ec2:us-east-1:{account_id}:vpc/vpc-123456789"
        ]
    )

def test_allow_create_network_interface(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "ec2:CreateNetworkInterface": "allowed"
        },
        resources=[
            "arn:aws:ec2:us-east-1:{account_id}:network-interface/ni-123456789",
            "arn:aws:ec2:us-east-1:{account_id}:subnet/sn-123456789"
        ]
    )

def test_allow_run_instances(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "ec2:RunInstances": "allowed"
        },
        resources=[
            "arn:aws:ec2:us-east-1::image/ami-123456789",
            "arn:aws:ec2:us-east-1:{account_id}:instance/i-123455",
            "arn:aws:ec2:us-east-1:{account_id}:network-interface/nic-12345",
            "arn:aws:ec2:us-east-1:{account_id}:security-group/sg-123456789",
            "arn:aws:ec2:us-east-1:{account_id}:subnet/sn-123456789",
        ]
    )

def test_deny_create_internet_gateway(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "ec2:CreateInternetGateway": "implicitDeny",
            "ec2:DeleteInternetGateway": "implicitDeny",
        },
        resources=[
            "arn:aws:ec2:us-west-2:{account_id}:internet-gateway/igw-0abcdef1234567890"
        ]
    )

def test_allow_tag_ec2(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "ec2:CreateTags": "allowed",
            "ec2:DeleteTags": "allowed",
        },
        resources=[
            "arn:aws:ec2:us-east-1:976193220746:instance/i-058f0f7ba302fb48d"
        ]
    )

def test_allow_describe_tags(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "ec2:DescribeTags": "allowed",
        },
        resources=[
        ]
    )

def test_allow_tag_other(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "lambda:TagResource": "allowed",
            "lambda:UntagResource": "allowed",
            "elasticache:UntagResource": "allowed",
        },
        resources=[
        ]
    )

def test_allow_resource_groups(sandbox_iam_client: IAMClient, sandbox_dev_role: RoleTypeDef):
    simulate_identity_policy(
        client=sandbox_iam_client,
        iam_role=sandbox_dev_role,
        action_expectations={
            "resource-groups:AssociateResource": "allowed"
        },
        resources=[
           "arn:aws:resource-groups:us-east-1:{account_id}:group/somegroup"
        ]
    )