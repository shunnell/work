############################# AWS-Support-Access-Role #########################################
#  █████╗ ██╗    ██╗███████╗      ███████╗██╗   ██╗██████╗ ██████╗  ██████╗ ██████╗ ████████╗ #
# ██╔══██╗██║    ██║██╔════╝      ██╔════╝██║   ██║██╔══██╗██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝ #
# ███████║██║ █╗ ██║███████╗█████╗███████╗██║   ██║██████╔╝██████╔╝██║   ██║██████╔╝   ██║    #
# ██╔══██║██║███╗██║╚════██║╚════╝╚════██║██║   ██║██╔═══╝ ██╔═══╝ ██║   ██║██╔══██╗   ██║    #
# ██║  ██║╚███╔███╔╝███████║      ███████║╚██████╔╝██║     ██║     ╚██████╔╝██║  ██║   ██║    #
# ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝      ╚══════╝ ╚═════╝ ╚═╝     ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝    #
#                                                                                             #
#  █████╗  ██████╗ ██████╗███████╗███████╗███████╗      ██████╗  ██████╗ ██╗     ███████╗     #
# ██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝      ██╔══██╗██╔═══██╗██║     ██╔════╝     #
# ███████║██║     ██║     █████╗  ███████╗███████╗█████╗██████╔╝██║   ██║██║     █████╗       #
# ██╔══██║██║     ██║     ██╔══╝  ╚════██║╚════██║╚════╝██╔══██╗██║   ██║██║     ██╔══╝       #
# ██║  ██║╚██████╗╚██████╗███████╗███████║███████║      ██║  ██║╚██████╔╝███████╗███████╗     #
# ╚═╝  ╚═╝ ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝      ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝     #
############################# AWS-Support-Access-Role #########################################                                                                                           
import click
import json
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError
from bespin_tools.lib.aws.sso import sso_and_account_list
from bespin_tools.lib.aws.util import paginate
# Defining role and policy for AWS Support Access
def create_support_role_and_policy(iam_client, role_name, policy_name):
    """
    Create an IAM role with AWSSupportAccess to manage incidents with AWS Support.
    """
    assume_role_policy_document = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "support.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            } 
        ]
    }

    # Custom policy for AWS support access
    policy_document = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "support:*"
                ],
                "Resource": "*"
            }
        ]
    }

    try:
        # Create the IAM role for AWS Support Access
        role = iam_client.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(assume_role_policy_document),
            Description="Role for AWS Support to manage incidents",
        )
        print(f"Role {role_name} created successfully.")

        # Create a customer-managed policy
        policy = iam_client.create_policy(
            PolicyName=policy_name,
            PolicyDocument=json.dumps(policy_document),
            Description="Policy to allow AWS Support access"
        )
        print(f"Managed policy {policy_name} created successfully.")

        # Attach the custom-managed policy to the role
        iam_client.attach_role_policy(
            RoleName=role_name,
            PolicyArn=policy['Policy']['Arn']
        )
        print(f"Policy attached to {role_name} successfully.")

    except ClientError as e:
        print(f"Error creating or attaching policy to the role {role_name}: {e}")

@click.group()
def AWSSupport():
    """ Group for AWS-related commands """
    pass

@AWSSupport.command()
def aws_support_access_role():
    """
    Command to create the 'AWSSupportAccess' IAM role in all accounts accessible via AWS SSO.
    """
    role_name = "AWSSupportAccess"
    policy_name = "AWSSupportAccessPolicy"
    # Fetch accounts using sso_and_account_list
    for account in sso_and_account_list('us-east-1'):  # Assuming `sso_and_account_list` manages SSO
        print(f"\n--- Processing Account: Account_ID= ({account.account_id}) Account_Name= ({account.account_name}) ---\n")
        try:
            # Initialize the IAM Client for the current account
            iam_client = account.client('iam')
            # Create the role in the account
            create_support_role_and_policy(iam_client, role_name, policy_name)  
            # List IAM roles in the account to verify if the role was created
            roles = list(paginate(iam_client, 'list_roles', 'Roles'))
            for role in roles:
                if "AWSSupportAccess" in role['RoleName']:
                    print(f"Role found: {role['RoleName']}")
        
        except ClientError as e:
            print(f"Error in account_id= ({account.account_id}) Account_Name= ({account.account_name}) ")

# CMD => rye run bespinctl AWSSupport aws-support-access-role
    
    
