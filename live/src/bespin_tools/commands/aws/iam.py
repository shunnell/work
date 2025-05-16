from __future__ import annotations

import csv
import datetime
import re
from collections import defaultdict
from functools import cache
from pathlib import Path
from typing import Tuple, Iterable

from tqdm import tqdm
import click
from types_boto3_identitystore.client import IdentityStoreClient
from types_boto3_sso_admin.client import SSOAdminClient

from bespin_tools.lib.aws import CLOUD_CITY_ORGANIZATION_ROOT_ACCOUNT
from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.arguments import AwsAccounts
from bespin_tools.lib.aws.iam import get_principal_id, assign_permission_set, get_instance_arn, get_permission_set_arn, remove_permission_set
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.logging import info

import time

from bespin_tools.lib.tables import BespinctlTable


@click.group()
@click.pass_context
def iam(ctx):
    root, = Organization.get_accounts(CLOUD_CITY_ORGANIZATION_ROOT_ACCOUNT)
    ctx.obj = root

@cache
def user_id_to_user_name(client: IdentityStoreClient, identity_store_id: str, user_id: str) -> str:
    response = client.describe_user(IdentityStoreId=identity_store_id, UserId=user_id)
    return response['UserName']

@cache
def permission_set_arn_to_name(client: SSOAdminClient, instance_arn: str, permission_set_arn: str) -> str:
    ps_details = client.describe_permission_set(InstanceArn=instance_arn, PermissionSetArn=permission_set_arn)
    return ps_details['PermissionSet']['Name']


def get_sso_ids(client: SSOAdminClient) -> Tuple[str, str]:
    response = client.list_instances()
    instances = response.get('Instances', [])
    assert len(instances) == 1, f"Expected 1 SSO Instances. Received {len(instances)}."
    instance_arn = instances[0]['InstanceArn']
    assert instance_arn != None
    identity_store_id = instances[0]['IdentityStoreId']
    assert identity_store_id != None
    return (instance_arn, identity_store_id)


@iam.command()
@click.argument('pattern', type=re.compile)
@click.option('-p', '--permissions-set-pattern', default=".*", type=re.compile, help="An optional additional filter to apply to permission set names.")
@click.pass_obj
def list_sso_groups_and_members(account: Account, pattern: str, permissions_set_pattern: str):
    identity_store_client = account.identity_store_client()
    identity_center_client = account.sso_admin_client()
    pattern_compiled = re.compile(pattern)
    permission_set_pattern_compiled = re.compile(permissions_set_pattern)

    instance_arn, identity_store_id = get_sso_ids(identity_center_client)

    groups = paginate(identity_store_client.list_groups, IdentityStoreId=identity_store_id)

    for group in groups:
        if pattern_compiled.match(group['DisplayName']):
            print('===================')
            print(group['DisplayName'])
            print('===================')
            has_match = False
            print('-----------------------')
            print("Permissions\tAccounts")
            print('-----------------------')
            account_assignments = paginate(
                identity_center_client.list_account_assignments_for_principal,
                PrincipalId=group['GroupId'],
                InstanceArn=instance_arn,
                PrincipalType='GROUP'
            )
            for account_assignment in account_assignments:
                account_id = account_assignment['AccountId']
                ps_arn = account_assignment['PermissionSetArn']
                ps_name = permission_set_arn_to_name(identity_center_client, instance_arn, ps_arn)
                if permission_set_pattern_compiled.match(ps_name):
                    has_match = True
                    print(f"{ps_name}\t{account_id}")

            group_memberships = paginate(
                identity_store_client.list_group_memberships,
                IdentityStoreId=identity_store_id,
                GroupId=group['GroupId']
            )
            if has_match:
                print('--------------')
                print('Group Members')
                print('--------------')
                for member in group_memberships:
                    user_id = member['MemberId']['UserId']
                    user_name = user_id_to_user_name(identity_store_client, identity_store_id, user_id)
                    print(user_name)


def _user_account_assignments(management_account: Account):
    identity_store_client = management_account.identity_store_client()
    identity_center_client = management_account.sso_admin_client()
    instance_arn, identity_store_id = get_sso_ids(identity_center_client)

    users = tuple(paginate(identity_store_client.list_users, IdentityStoreId=identity_store_id))
    rv = defaultdict(set)
    for user in tqdm(users):
        fname, lname = user['Name']['FamilyName'], user['Name']['GivenName']
        for assignment in paginate(
            identity_center_client.list_account_assignments_for_principal,
            InstanceArn=instance_arn,
            PrincipalType="USER",
            PrincipalId=user['UserId']
        ):
            if assignment['PrincipalType'] == 'USER':
                permission_set_name = permission_set_arn_to_name(
                    identity_center_client,
                    instance_arn,
                    assignment['PermissionSetArn'],
                )
                rv[(fname, lname, permission_set_name)].add(assignment['AccountId'])
    return rv


@iam.command()
@click.pass_obj
@click.option('--accounts', default="all", type=AwsAccounts())
def list_direct_account_assignments(management_account: Account, accounts: Iterable[Account]):
    """
    Iterate over every user in the identity store and check if they have been directly assigned permissions for an account.
    NOTE: This program is quite slow due to the APIs it uses. Be patient.
    Prints a table of users and account memberships.
    """
    with BespinctlTable(['Account', 'First Name', 'Last Name', 'Permission Set Name']) as table:
        for (fname, lname, permissionset), member_of_accounts in _user_account_assignments(management_account).items():
            for account in accounts:
                if account.account_id in member_of_accounts:
                    table.add_row(account, fname, lname, permissionset)

@iam.command()
def list_static_users():
    """
    Prints static (key/secret or password) IAM users in all BESPIN AWS accounts.

    This type of user should never exist! It is a serious violation of BESPIN's security plan to have a static IAM user.
    Given that, this command exists to print a to-do list of users to remove, and/or for use as a scanner to continually
    validate that no such users exist.
    """

    for account in sorted(Organization.get_accounts(Organization.ALL)):
        client = account.iam_client()
        for user in paginate(client.list_users):
            print(account, user)

@iam.command()
@click.option('-o', '--output-file', default=f"bespin-users-{datetime.datetime.strftime(datetime.datetime.today(),"%Y-%m-%d")}.csv", type=str, help="File to write results to")
@click.pass_obj
def list_sso_users(account: Account, output_file: str):
    """
    List every user in BESPIN and the groups they are assigned to.
    """
    identity_store_client = account.identity_store_client()
    identity_center_client = account.sso_admin_client()
    instance_arn, identity_store_id = get_sso_ids(identity_center_client)
    users = paginate(identity_store_client.list_users, IdentityStoreId=identity_store_id)
    assert Path(output_file).exists == False
    with open(output_file, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['UserId', 'UserName', 'FullName', "Groups"])
        for user in users:
            memberships = paginate(identity_store_client, 'list_group_memberships_for_member', 'GroupMemberships', IdentityStoreId=identity_store_id, MemberId={'UserId': user['UserId']})
            memberships = [group_id_to_group_name(identity_store_client, identity_store_id, membership['GroupId']) for membership in memberships]
            writer.writerow([user['UserId'], user['UserName'], f"{user['Name']['GivenName']} {user['Name']['FamilyName']}", f"{";".join(memberships)}"])

@iam.command()
@click.argument('account_name')
@click.argument('permission_set_name')
def temp_assign_permissions_set(account_name: str, permission_set_name: str):
    mgmt_accout,  = Organization.get_accounts(CLOUD_CITY_ORGANIZATION_ROOT_ACCOUNT)
    target_account, = Organization.get_accounts(account_name)

    account_id = target_account.account_id

    sso_client = mgmt_accout.sso_admin_client()
    sts_client = mgmt_accout.sts_client()
    identitystore_client = mgmt_accout.identity_store_client()

    instance_arn, identity_store_id = get_instance_arn(sso_client)
    permission_set_arn = get_permission_set_arn(sso_client, permission_set_name, instance_arn)
    principal_id = get_principal_id(sts_client, identitystore_client, instance_arn, identity_store_id)
    principal_type = 'USER'

    assign_permission_set(sso_client, permission_set_arn, account_id, instance_arn, principal_id, principal_type)
    info(f"Assigned permission set {permission_set_name} to user {principal_id} for account {account_name}({account_id})")
    info("Sleeping indefinitely. Press Ctrl+C to exit and remove the account assignment.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        remove_permission_set(sso_client, permission_set_arn, account_id, instance_arn, principal_id, principal_type)
        info(f"Removed permission set {permission_set_name} to user {principal_id} for account {account_name}({account_id})")
