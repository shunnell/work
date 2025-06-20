from __future__ import annotations

from typing import Literal, TYPE_CHECKING
from bespin_tools.lib.aws.util import paginate

if TYPE_CHECKING:
    from types_boto3_sso_admin.client import SSOAdminClient

def get_instance_arn(sso_client):
    response = sso_client.list_instances()
    if 'Instances' in response and len(response['Instances']) > 0:
        return (response['Instances'][0]['InstanceArn'], response['Instances'][0]['IdentityStoreId'])
    raise Exception("No SSO instances found")

def get_permission_set_arn(sso_client: SSOAdminClient, permission_set_name: str, instance_arn: str):
    response = paginate(sso_client.list_permission_sets, InstanceArn=instance_arn)
    for permission_set_arn in response:
        details = sso_client.describe_permission_set(
            InstanceArn=instance_arn,
            PermissionSetArn=permission_set_arn
        )
        if details['PermissionSet']['Name'] == permission_set_name:
            return permission_set_arn
    raise Exception(f"Permission set {permission_set_name} not found")

def assign_permission_set(sso_client: SSOAdminClient, permission_set_arn: str, account_id: str, instance_arn: str, principal_id: str, principal_type: Literal['GROUP'] | Literal['USER']):
    response = sso_client.create_account_assignment(
        InstanceArn=instance_arn,
        TargetId=account_id,
        TargetType='AWS_ACCOUNT',
        PermissionSetArn=permission_set_arn,
        PrincipalType=principal_type,
        PrincipalId=principal_id
    )
    return response

def remove_permission_set(sso_client: SSOAdminClient, permission_set_arn, account_id, instance_arn, principal_id, principal_type):
    response = sso_client.delete_account_assignment(
        InstanceArn=instance_arn,
        TargetId=account_id,
        TargetType='AWS_ACCOUNT',
        PermissionSetArn=permission_set_arn,
        PrincipalType=principal_type,
        PrincipalId=principal_id
    )
    return response


def get_principal_id(sts_client, identitystore_client, instance_arn, identity_store_id):
    response = sts_client.get_caller_identity()
    current_user_arn = response['Arn']
    current_user_id = current_user_arn.split('/')[-1]
    users = paginate(identitystore_client.list_users, IdentityStoreId=identity_store_id)
    for user in users:
        if user['UserName'] == current_user_id:
            return user['UserId']
    raise Exception("User ID not found in IAM Identity Center")