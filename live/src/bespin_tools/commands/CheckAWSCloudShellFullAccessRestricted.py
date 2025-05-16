###################### CloudShell-Full-Access Report #######################################
#  ██████╗██╗      ██████╗ ██╗   ██╗██████╗       ███████╗██╗  ██╗███████╗██╗     ██╗      #
# ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗      ██╔════╝██║  ██║██╔════╝██║     ██║      #
# ██║     ██║     ██║   ██║██║   ██║██║  ██║█████╗███████╗███████║█████╗  ██║     ██║      #
# ██║     ██║     ██║   ██║██║   ██║██║  ██║╚════╝╚════██║██╔══██║██╔══╝  ██║     ██║      #
# ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝      ███████║██║  ██║███████╗███████╗███████╗ #
#  ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝       ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝ #
#                                                                                          #
# ███████╗██╗   ██╗██╗     ██╗          █████╗  ██████╗ ██████╗███████╗███████╗███████╗    #
# ██╔════╝██║   ██║██║     ██║         ██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝    #
# █████╗  ██║   ██║██║     ██║         ███████║██║     ██║     █████╗  ███████╗███████╗    #
# ██╔══╝  ██║   ██║██║     ██║         ██╔══██║██║     ██║     ██╔══╝  ╚════██║╚════██║    #
# ██║     ╚██████╔╝███████╗███████╗    ██║  ██║╚██████╗╚██████╗███████╗███████║███████║    #
# ╚═╝      ╚═════╝ ╚══════╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝    #
#                                                                                          #
# ██████╗ ███████╗██████╗  ██████╗ ██████╗ ████████╗                                       #
# ██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝                                       #
# ██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝   ██║                                          #
# ██╔══██╗██╔══╝  ██╔═══╝ ██║   ██║██╔══██╗   ██║                                          #
# ██║  ██║███████╗██║     ╚██████╔╝██║  ██║   ██║                                          #
# ╚═╝  ╚═╝╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝                                          #
###################### CloudShell-Full-Access Report #######################################                                                                                      
import click
import json
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError
from bespin_tools.lib.aws.sso import sso_and_account_list
from bespin_tools.lib.aws.util import paginate

def has_cloudshell_access(policy_document):
    """
    Check if a policy document grants AWS CloudShell access.
    """
    for statement in policy_document.get("Statement", []):
        if statement.get("Effect") == "Allow":
            actions = statement.get("Action", [])
            resources = statement.get("Resource", [])
            
            if not isinstance(actions, list):
                actions = [actions] 
            if not isinstance(resources, list):
                resources = [resources]            
            for action in actions:      
                if "cloudshell:*" in actions:
                    return True
    return False 

def is_admin_policy(policy_document):
    """
    Check if a Policy document grants admin access
    """
    for statement in policy_document.get("Statement", []):
        if statement.get("Effect") == "Allow":
            actions = statement.get("Action", [])
            resources = statement.get("Resource", [])
            if not isinstance(actions, list):
                actions = [actions] 
            if not isinstance(resources, list):
                resources = [resources]              
            for action in actions:      
                if "*" in actions and "*" in resources:
                    return True 
    return False       

@click.group()
def cloudshell():
    """ Group for AWS-related commands """
    pass

@cloudshell.command()
def restrict_cloudshell_access():
    """
    Identify and restrict cloudshell access for users, roles and policies across all accounts.
    """
    # Get the current UTC time
    utc_now = datetime.utcnow().replace(tzinfo=timezone.utc)
    # Get all accounts using SSO (this handles account list and session handling)
    for account in sso_and_account_list('us-east-1'):  # Assuming `sso_and_account_list` manages SSO
        print(f"\n--- Processing Account: Account_ID= ({account.account_id}) Account_Name= ({account.account_name}) ---\n") 
        users_with_access = []
        users_without_access = []
        roles_with_access = []
        roles_without_access = []             
        try:
            # Use the account session to create the IAM client
            iam_client = account.client('iam')
            # Check all IAM users
            users = list(paginate(iam_client, 'list_users', 'Users'))
            for user in users:
                user_name = user['UserName']
                has_access = False 
                attached_policies = list(paginate(iam_client, 'list_attached_user_policies', 'AttachedPolicies', UserName=user_name))
                for policy in attached_policies:
                    policy_arn = policy['PolicyArn']
                    policy_name = policy['PolicyName']
                    policy_version = iam_client.get_policy_version(PolicyArn=policy_arn, VersionId=iam_client.get_policy(PolicyArn=policy_arn)['Policy']['DefaultVersionId']) 
                    policy_document = policy_version['PolicyVersion']['Document']
                    if has_cloudshell_access(policy_document) or is_admin_policy(policy_document):
                        has_access = True
                        break
                        # Detach the policy
                        # iam_client.detach_user_policy(UserName=user_name, PolicyArn=policy_arn)
                if not has_access:        
                    # Check inline policies
                    inline_policies = list(paginate(iam_client, 'list_user_policies', 'PolicyNames', UserName=user_name))
                    for inline_policy_name in inline_policies:
                        policy_document = iam_client.get_user_policy(UserName=user_name, PolicyName=inline_policy_name)['PolicyDocument']
                        if has_cloudshell_access(policy_document) or is_admin_policy(policy_document):
                            has_access = True
                            break
                            # Optionally delete the inline policy
                            # iam_client.delete_user_policy(UserName=user_name, PolicyName=inline_policy_name)
              
                if has_access:
                    users_with_access.append(user_name)
                else:
                    users_without_access.append(user_name)
                        
            # Check all IAM roles
            roles = list(paginate(iam_client, 'list_roles', 'Roles'))
            for role in roles:
                role_name = role['RoleName']
                has_access = False 
                attached_policies = list(paginate(iam_client, 'list_attached_role_policies', 'AttachedPolicies', RoleName=role_name))

                for policy in attached_policies:
                    policy_arn = policy['PolicyArn']
                    policy_name = policy['PolicyName']
                    policy_version = iam_client.get_policy_version(PolicyArn=policy_arn, VersionId=iam_client.get_policy(PolicyArn=policy_arn)['Policy']['DefaultVersionId']) 
                    policy_document = policy_version['PolicyVersion']['Document']                    
                    if has_cloudshell_access(policy_document) or is_admin_policy(policy_document):
                        has_access = True
                        break                    
                         # Optionally detach the policy
                         # iam_client.detach_role_policy(RoleName=role_name, PolicyArn=policy_arn)
                
                if not has_access:
                    inline_policies = list(paginate(iam_client, 'list_role_policies', 'PolicyNames', RoleName=role_name))
                    for inline_policy_name in inline_policies:
                        policy_document = iam_client.get_role_policy(RoleName=role_name, PolicyName=inline_policy_name)['PolicyDocument']
                        if has_cloudshell_access(policy_document) or is_admin_policy(policy_document):
                            has_access = True
                            break                 
                            # Optionally delete the inline policy
                            # iam_client.delete_role_policy(RoleName=role_name, PolicyName=inline_policy_name) 
                
                if has_access:
                    roles_with_access.append(role_name)
                else:
                    roles_without_access.append(role_name)
             

            print("\n--- Users With CloudShell Access ----")
            print("\n".join(users_with_access) if users_with_access else "None")
            print("\n--- Users Without CloudShell Access ----")
            print("\n".join(users_without_access) if users_without_access else "None")
            print("\n--- Roles With CloudShell Access ----")
            print("\n".join(roles_with_access) if roles_with_access else "None")
            print("\n--- Roles Without CloudShell Access ----")
            print("\n".join(roles_without_access) if roles_without_access else "None")


        except ClientError as ex:
                print(f"Error checking cloudshellaccess for user {user_name} in account {account.account_name}: {ex}")
        except Exception as e:
                print(f"Unexpected error cloudshellaccess for user {user_name} in {account.account_name}: {e}")

# CMD => rye run bespinctl cloudshell restrict-cloudshell-access