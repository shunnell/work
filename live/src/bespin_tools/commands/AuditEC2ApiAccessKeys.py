############################### AuditEC2ApiAccessKeys #######################################
#  █████╗ ██╗   ██╗██████╗ ██╗████████╗   ███████╗ ██████╗██████╗        █████╗ ██████╗ ██╗ #
# ██╔══██╗██║   ██║██╔══██╗██║╚══██╔══╝   ██╔════╝██╔════╝╚════██╗      ██╔══██╗██╔══██╗██║ #
# ███████║██║   ██║██║  ██║██║   ██║█████╗█████╗  ██║      █████╔╝█████╗███████║██████╔╝██║ #
# ██╔══██║██║   ██║██║  ██║██║   ██║╚════╝██╔══╝  ██║     ██╔═══╝ ╚════╝██╔══██║██╔═══╝ ██║ #
# ██║  ██║╚██████╔╝██████╔╝██║   ██║      ███████╗╚██████╗███████╗      ██║  ██║██║     ██║ #
# ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝   ╚═╝      ╚══════╝ ╚═════╝╚══════╝      ╚═╝  ╚═╝╚═╝     ╚═╝ #
#                                                                                           #
#  █████╗  ██████╗ ██████╗███████╗███████╗███████╗      ██╗  ██╗███████╗██╗   ██╗███████╗   #
# ██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝      ██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔════╝   #
# ███████║██║     ██║     █████╗  ███████╗███████╗█████╗█████╔╝ █████╗   ╚████╔╝ ███████╗   #
# ██╔══██║██║     ██║     ██╔══╝  ╚════██║╚════██║╚════╝██╔═██╗ ██╔══╝    ╚██╔╝  ╚════██║   #
# ██║  ██║╚██████╗╚██████╗███████╗███████║███████║      ██║  ██╗███████╗   ██║   ███████║   #
# ╚═╝  ╚═╝ ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝      ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝   #
############################### AuditEC2ApiAccessKeys #######################################
import click
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError
from bespin_tools.lib.aws.sso import sso_and_account_list
from bespin_tools.lib.aws.util import paginate
import os

@click.group()
def ec2instance():
    """ Group for AWS-related commands """
    pass

@ec2instance.command()
def audit_instances():
    """
    Audit EC2 instances for hardcorded AWS keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) across all accounts and regions.
    """
    # Get the current UTC time
    utc_now = datetime.utcnow().replace(tzinfo=timezone.utc)

    # Fetch accounts using sso_and_account_list
    for account in sso_and_account_list('us-east-1'): 
        print(f"\n--- Processing Account: Account_ID= ({account.account_id}) Account_Name= ({account.account_name}) ---\n")
        try:
            # Initialize the ec2 Client for the current account
            ec2_client = account.client('ec2')
            ssm_client = account.client('ssm')
            sts_client = account.client('sts')
            # List all EC2 instances in the account
            instances = list(paginate(ec2_client, 'describe_instances', 'Reservations'))
            for reservation in instances:
                for instance in reservation['Instances']:
                    instance_id = instance['InstanceId']
                    print(f"Checking instance {instance_id} in account {account.account_name}...")
                    # Check if the instance is managed by ssm
                    try:
                        ssm_response = ssm_client.describe_instance_information(
                            Filters=[{'Key': 'InstanceIds', 'Values': [instance_id]}]
                        )

                        # If no managed instances found, report it
                        if not ssm_response['InstanceInformationList']:
                            # Check file path on every instance
                            check_instance_credentials(instance_id)
                            print(f"Inspecting metadata")
                            inspect_instance_metadata(ec2_client, instance_id)
                            continue

                        # Run command to search for AWS Keys
                        response = ssm_client.send_command(
                            InstanceIds=[instance_id],
                            DocumentName="AWS-RunShellScript",
                            Parameters={
                                'commands': [
                                    "grep -r 'AWS_ACCESS_KEY_ID' /etc / --exclude-dir={/proc,/sys,/dev}",
                                    "grep -r 'AWS_SECRET_ACCESS_KEY' /etc / --exclude-dir={/proc,/sys,/dev}",
                                    "grep -r 'AWS_ACCESS_KEY_ID' /home / --exclude-dir={/proc,/sys,/dev}",
                                    "grep -r 'AWS_SECRET_ACCESS_KEY' /home / --exclude-dir={/proc,/sys,/dev}"
                                ]
                            }
                        )

                        command_id = response['Command']['CommandId']
                        invocation = ssm_client.get_command_invocation(CommandId=command_id, InstanceId=instance_id)

                        if invocation['Status'] == 'Success' and invocation['StandardOutputContent']:
                            print(f"Hardcoded AWS keys found on instance {instance_id} in account {account.account_name}:")
                            print(invocation['StandardOutputContent'])
                        else:
                            print(f"No hardcoded AWS ACCESS keys found on this instance {instance_id}.")

                    except ClientError as e:
                        print(f"Issue with instance {instance_id}: {e}")
                    except Exception as e:
                        print(f"Unexpected error for instance {instance_id}: {e}")

        except ClientError as e:
            print(f"Error processing account {account.account_id} ({account.account_name}): {e}")
        except Exception as e:
            print(f"Unexpected error in account {account.account_id} ({account.account_id}): {e}")

def inspect_instance_metadata(ec2_client, instance_id):
    """
    Fallback to inspect instance metadata and IAM instance profile.
    """
    try:
        instance_description = ec2_client.describe_instances(InstanceIds=[instance_id])
        instance_details = instance_description['Reservations'][0]['Instances'][0]
        iam_instance_profile = instance_details.get('IamInstanceProfile')
        if iam_instance_profile:
            print(f"Instance {instance_id} has IAM Instance Profile: {iam_instance_profile['Arn']}")
        else:
            print(f"Instance {instance_id} does not have IAM Instance Profile.")

    except ClientError as e:
        print(f"error retrieving details for instance {instance_id}: {e}")
    except Exception as e:
        print(f"error retrieving details for instance {instance_id}: {e}")

def check_instance_credentials(instance_id):
    """
    Check if AWS credentials are stored on the EC2 instance in local files.
    """
    # Common AWS credentials file locations
    aws_credentials_files = [
        '/home/ec2-user/.aws/credentials',
        '/home/ubuntu/.aws/credentials',
        '/etc/.aws/credentials',
        '/etc/.aws/config'
    ]

    for file_path in aws_credentials_files:
        if os.path.exists(file_path):
            with open(file_path, 'r') as file:
                content = file.read()
                if 'AWS_ACCESS_KEY_ID' in content or 'AWS_SECRET_ACCESS_KEY' in content:
                    print(f"AWS Credentials found in file {file_path} on instance {instance_id}.")
                else:
                    print(f"No AWS credentials found in file {file_path}.")

        else:
            print(f"NO AWS Credentials file found at {file_path}")



# CMD ==> rye run bespinctl ec2instance audit-instances


      

            
