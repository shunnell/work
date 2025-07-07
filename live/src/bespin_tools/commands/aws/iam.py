from __future__ import annotations

import csv
import datetime
import re
from collections import defaultdict
from dataclasses import dataclass
from functools import cache
from json import dumps
from pathlib import Path
from typing import Tuple, Iterable, TYPE_CHECKING, Collection

from tqdm import tqdm
import click
from arn import Arn
from arn.iam import RoleArn

from bespin_tools.lib.argument_types import Regex
from bespin_tools.lib.aws import CLOUD_CITY_ORGANIZATION_ROOT_ACCOUNT
from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.arguments import AwsAccounts
from bespin_tools.lib.aws.iam import get_principal_id, assign_permission_set, get_instance_arn, get_permission_set_arn, remove_permission_set
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.logging import info

import time

from bespin_tools.lib.tables import BespinctlTable

if TYPE_CHECKING:
    from types_boto3_identitystore.client import IdentityStoreClient
    from types_boto3_sso_admin.client import SSOAdminClient


@dataclass
class PolicyArn(Arn):
    """ARN for an `IAM Role <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html>`_."""

    REST_PATTERN = re.compile(r"policy/(?P<name>.*)")

    name: str = ""


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
    BespinctlError.invariant(len(instances) == 1, f"Expected 1 SSO Instances. Received {len(instances)}")
    instance_arn = instances[0]['InstanceArn']
    BespinctlError.invariant(instance_arn != None, "Instance ARN is None")
    identity_store_id = instances[0]['IdentityStoreId']
    BespinctlError.invariant(identity_store_id != None, "Identity store ID is None")
    return instance_arn, identity_store_id


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
    BespinctlError.invariant(Path(output_file).exists == False, f"Output file already exists: {output_file}")
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

def _is_sandbox_role(arn: RoleArn):
    if arn.name.startswith('sandbox') or '/sandbox' in arn.name:
        # False positives:
        if arn.account == '381492150796' and arn.name.startswith(('sandbox-cluster', 'sandbox-general-eks-node-group')):
            return False
        return True
    return False

def _roles_and_boundaries(accounts: Collection[Account]):
    for account in accounts:
        client = account.iam_client()
        desired_boundary = PolicyArn(f"arn:aws:iam::{account.account_id}:policy/platform/SandboxPermissionsBoundary")
        client.get_policy(PolicyArn=str(desired_boundary))  # Validate that it exists
        for role in paginate(client.list_roles):
            # Work around boto bug: https://github.com/boto/boto3/issues/1623
            role = client.get_role(RoleName=role['RoleName'])['Role']
            yield account, role, desired_boundary


@iam.command()
@click.option('--accounts', default="730335639457", type=AwsAccounts())
@click.option( '--execute', is_flag=True, default=False)
def apply_sandbox_permission_boundary(accounts: Collection[Account], execute: bool):
    to_change = []
    for account, role, desired_boundary in tqdm(_roles_and_boundaries(accounts)):
        client = account.iam_client()
        arn = RoleArn(role['Arn'])
        current_boundary = role.get('PermissionsBoundary', dict()).get('PermissionsBoundaryArn')
        if current_boundary is not None:
            current_boundary = PolicyArn(current_boundary)

        if _is_sandbox_role(arn) and current_boundary != desired_boundary:
            to_change[(account, arn)] = (current_boundary, desired_boundary)

    for (account, arn), (current_boundary, desired_boundary) in to_change:
        msg = f"{account}: Role {arn} has permissions boundary {current_boundary}; changing boundary to {desired_boundary}"
        if execute:
            info(msg)
            client.put_role_permissions_boundary(RoleName=role['RoleName'], PermissionsBoundary=str(desired_boundary))
        else:
            info(f"(pass --execute to make changes) {msg}")

def _json_iam_document(document) -> str:
    return dumps(
        document,
        sort_keys=True,
        # Boto3 returns things with datetimes in 'em:
        # https://stackoverflow.com/questions/12122007/python-json-encoder-to-support-datetime
        default=lambda o: o.isoformat() if hasattr(o, 'isoformat') else o
    )


@iam.command()
@click.option('--accounts', default="all", type=AwsAccounts())
@click.argument( 'pattern', type=Regex())
def grep(accounts: Collection[Account], pattern: Regex.Pattern):
    with BespinctlTable(['Account', 'Entity type', 'Matches', 'Uses', 'Name', 'Arn']) as table:
        for account in Organization.get_accounts(*accounts):
            client = account.iam_client()
            for account, role, _ in tqdm(_roles_and_boundaries([account]), desc="Roles"):
                if matches := pattern.findall(_json_iam_document(role)):
                    arn = RoleArn(role['Arn'])
                    if str(arn).startswith('arn:aws:iam::aws:'):
                        kind = 'Role (AWS)'
                    else:
                        kind = 'Role (Customer)'
                    table.add_row(account, kind, len(matches), '<unknown>', arn.name, arn)
            for policy in tqdm(paginate(client.list_policies), desc="Policies"):
                arn = PolicyArn(policy['Arn'])
                uses = str(policy['AttachmentCount'])
                if boundary_uses := policy['PermissionsBoundaryUsageCount']:
                    uses = f"{uses} ({boundary_uses} as boundary)"

                policy = client.get_policy_version(PolicyArn=str(arn), VersionId=policy['DefaultVersionId'])['PolicyVersion']
                if matches := pattern.findall(_json_iam_document(policy)):
                    if str(arn).startswith('arn:aws:iam::aws:'):
                        kind = 'Policy (AWS)'
                    else:
                        kind = 'Policy (Customer)'
                    table.add_row(account, kind, len(matches), uses, arn.name, arn)
