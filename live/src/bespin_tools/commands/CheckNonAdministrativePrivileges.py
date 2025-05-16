################### Non-Admin Privilege #######################################
# ███╗   ██╗ ██████╗ ███╗   ██╗       █████╗ ██████╗ ███╗   ███╗██╗███╗   ██╗ #
# ████╗  ██║██╔═══██╗████╗  ██║      ██╔══██╗██╔══██╗████╗ ████║██║████╗  ██║ #
# ██╔██╗ ██║██║   ██║██╔██╗ ██║█████╗███████║██║  ██║██╔████╔██║██║██╔██╗ ██║ #
# ██║╚██╗██║██║   ██║██║╚██╗██║╚════╝██╔══██║██║  ██║██║╚██╔╝██║██║██║╚██╗██║ #
# ██║ ╚████║╚██████╔╝██║ ╚████║      ██║  ██║██████╔╝██║ ╚═╝ ██║██║██║ ╚████║ #
# ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝      ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ #
#                                                                             #
# ██████╗ ██████╗ ██╗██╗   ██╗██╗██╗     ███████╗ ██████╗ ███████╗            #
# ██╔══██╗██╔══██╗██║██║   ██║██║██║     ██╔════╝██╔════╝ ██╔════╝            #
# ██████╔╝██████╔╝██║██║   ██║██║██║     █████╗  ██║  ███╗█████╗              #
# ██╔═══╝ ██╔══██╗██║╚██╗ ██╔╝██║██║     ██╔══╝  ██║   ██║██╔══╝              #
# ██║     ██║  ██║██║ ╚████╔╝ ██║███████╗███████╗╚██████╔╝███████╗            #
# ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝            #
################### Non-Admin Privilege #######################################
import click
import json
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError
from bespin_tools.lib.aws.sso import sso_and_account_list
from bespin_tools.lib.aws.util import paginate

def is_admin_policy(policy_document):
    """
    Check if a policy document grants administrator-level permissions.
    """
    for statement in policy_document.get("Statement", []):
        if statement.get("Effect") == "Allow":
            actions = statement.get("Action", [])
            resources = statement.get("Resource", [])

            if not isinstance(actions, list):
                actions = [actions]
            if not isinstance(resources, list):
                resources = [resources]
            if "*" in actions and "*" in resources:
                return True

    return False 

@click.group()
def nonadministrator():
    """ Group for AWS-related commands """
    pass

@nonadministrator.command()
def non_admin_privileges():
    """
    Identify and restrict administrator privileges for users, roles, and policies across all accounts.
    """
    # Get the current UTC time
    utc_now = datetime.utcnow().replace(tzinfo=timezone.utc)
    # Get all accounts using SSO (this handles account list and session handling)
    for account in sso_and_account_list('us-east-1'):  # Assuming `sso_and_account_list` manages SSO
        print(f"\n--- Processing Account: Account_ID= ({account.account_id}) Account_Name= ({account.account_name}) ---\n")  
        # Separate lists for users and roles with and without admin privileges
        admin_users = []
        non_admin_users = []
        admin_roles = []
        non_admin_roles = []  
        admin_policies = []
        non_admin_policies = []
        try:
            # Use the account session to create the IAM client
            iam_client = account.client('iam')

            # Check all IAM users
            users = list(paginate(iam_client, 'list_users', 'Users'))
            for user in users:
                user_name = user['UserName']
                has_admin_privileges = False

                # Check attached policies
                attached_policies = list(paginate(iam_client, 'list_attached_user_policies', 'AttachedPolicies', UserName=user_name))
                for policy in attached_policies:
                    if policy['PolicyName'] == "AdministratorAccess":
                        has_admin_privileges = True
                        # Optionally detach the policy
                        # iam_client.detach_user_policy(UserName=user_name, PolicyArn=policy['PolicyArn'])
                        break 
                # check inline policies
                if not has_admin_privileges:
                    inline_policies = list(paginate(iam_client, 'list_user_policies', 'PolicyNames', UserName=user_name))
                    for inline_policy_name in inline_policies:
                        policy_document = iam_client.get_user_policy(UserName=user_name, PolicyName=inline_policy_name)['PolicyDocument']
    
                        if is_admin_policy(policy_document):
                            has_admin_privileges = True
                            # Optionally delete the inline policy
                            # iam_client.delete_user_policy(UserName=user_name, PolicyName=inline_policy_name)
                            break 
                # Add user to appropriate list
                if has_admin_privileges:
                    admin_users.append(user_name)
                else:
                    non_admin_users.append(user_name)
            
            # Check all IAM roles
            roles = list(paginate(iam_client, 'list_roles', 'Roles'))
            for role in roles:
                role_name = role['RoleName']
                has_admin_privileges = False 
                # Check attached policies
                attached_policies = list(paginate(iam_client, 'list_attached_role_policies', 'AttachedPolicies', RoleName=role_name))
                for policy in attached_policies:
                    if policy['PolicyName'] == "AdministratorAccess":
                        has_admin_privileges = True 
                         # Optionally detach the policy
                         # iam_client.detach_role_policy(RoleName=role_name, PolicyArn=policy['PolicyArn'])
                        break 
                # check inline policies
                if not has_admin_privileges:
                    inline_policies = list(paginate(iam_client, 'list_role_policies', 'PolicyNames', RoleName=role_name))
                    for inline_policy_name in inline_policies:
                        policy_document = iam_client.get_role_policy(RoleName=role_name, PolicyName=inline_policy_name)['PolicyDocument']
                        if is_admin_policy(policy_document):
                            has_admin_privileges =True
                            # Optionally delete the inline policy
                            # iam_client.delete_role_policy(RoleName=role_name, PolicyName=inline_policy_name) 
                            break
                    
                # Add role to appropriate list
                if has_admin_privileges:
                    admin_roles.append(role_name)
                else:
                    non_admin_roles.append(role_name)
             
            # Check all managed policies
            policies = list(paginate(iam_client, 'list_policies', 'Policies', Scope='Local'))
            for policy in policies:
                policy_arn = policy['Arn']
                policy_name = policy['PolicyName']

                # Skip AWS managed policies
                if policy.get('Arn', '').startswith('arn:aws:iam::aws:policy/'):
                    continue

                # get the policy version
                policy_version_id = policy['DefaultVersionId']
                policy_version = iam_client.get_policy_version(PolicyArn=policy_arn, VersionId=policy_version_id)['PolicyVersion']

                if is_admin_policy(policy_version['Document']):
                    admin_policies.append(policy_name)
                    # Optionally delete the policy
                    # iam_client.delete_policy(PolicyArn=policy_arn)
                else:
                    non_admin_policies.append(policy_name)
            

            print("\nUsers without Admin Privileges:")
            for user in non_admin_users:
                print(f"  - {user}")

            print("\nroles without Admin Privileges:")
            for role in non_admin_roles:
                print(f"  - {role}")


        except ClientError as ex:
                print(f"Error checking Access keys for user {user_name} in account {account.account_name}: {ex}")
        except Exception as e:
                print(f"Unexpected error checking Access keys for user {user_name} in {account.account_name}: {e}")

# CMD => rye run bespinctl nonadministrator non-admin-privileges