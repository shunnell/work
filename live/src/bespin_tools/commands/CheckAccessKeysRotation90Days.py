#################################### 90DaysAccessKeyRotation #####################################################################################
#   █████╗  ██████╗       ██████╗  █████╗ ██╗   ██╗███████╗       █████╗  ██████╗ ██████╗███████╗███████╗███████╗      ██╗  ██╗███████╗██╗   ██╗ #
#  ██╔══██╗██╔═████╗      ██╔══██╗██╔══██╗╚██╗ ██╔╝██╔════╝      ██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝      ██║ ██╔╝██╔════╝╚██╗ ██╔╝ #
#  ╚██████║██║██╔██║█████╗██║  ██║███████║ ╚████╔╝ ███████╗█████╗███████║██║     ██║     █████╗  ███████╗███████╗█████╗█████╔╝ █████╗   ╚████╔╝  #
#   ╚═══██║████╔╝██║╚════╝██║  ██║██╔══██║  ╚██╔╝  ╚════██║╚════╝██╔══██║██║     ██║     ██╔══╝  ╚════██║╚════██║╚════╝██╔═██╗ ██╔══╝    ╚██╔╝   #
#   █████╔╝╚██████╔╝      ██████╔╝██║  ██║   ██║   ███████║      ██║  ██║╚██████╗╚██████╗███████╗███████║███████║      ██║  ██╗███████╗   ██║    #
#   ╚════╝  ╚═════╝       ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝ ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝      ╚═╝  ╚═╝╚══════╝   ╚═╝    #
#                                                                                                                                                #
#  ██████╗  ██████╗ ████████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗                                                                             #
#  ██╔══██╗██╔═══██╗╚══██╔══╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║                                                                             #
#  ██████╔╝██║   ██║   ██║   ███████║   ██║   ██║██║   ██║██╔██╗ ██║                                                                             #
#  ██╔══██╗██║   ██║   ██║   ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║                                                                             #
#  ██║  ██║╚██████╔╝   ██║   ██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║                                                                             #
#  ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝                                                                             #
#################################### 90DaysAccessKeyRotation #####################################################################################                                                                                                                                           


import click
import json
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError
from bespin_tools.lib.aws.sso import sso_and_account_list
from bespin_tools.lib.aws.util import paginate

@click.group()
def accesskey():
    """ Group for AWS-related commands """
    pass

@accesskey.command()
def access_key_rotation():
    """
    List IAM user credentials across all accounts and regions.
    """
    # Get the current UTC time
    utc_now = datetime.utcnow().replace(tzinfo=timezone.utc)
    # Set the inactivity threshold (45days)
    rotation_threshold = utc_now - timedelta(days=90)
    # Get all accounts using SSO (this handles account list and session handling)
    for account in sso_and_account_list('us-east-1'):  # Assuming `sso_and_account_list` manages SSO
        print(f"\n--- Processing Account: Account_ID= ({account.account_id}) Account_Name= ({account.account_name}) ---\n")
        try:
                # Use the `account.client` for the iam client and secrets manager clients
                iam_client = account.client('iam')
                # secrets_manager_client = account.client('secretsmanager')
                # List all iam users in the account
                users = list(paginate(iam_client, 'list_users', 'Users'))
                for user in users:
                    user_name = user['UserName']
                    # List access keys for each user
                    access_keys = list(paginate(iam_client, 'list_access_keys', 'AccessKeyMetadata', UserName=user_name))

                    for key in access_keys:
                        access_key_id = key['AccessKeyId']
                        create_date = key['CreateDate']

                        if create_date <= rotation_threshold:
                            print(f"access key {access_key_id} for user {user_name} in account {account.account_name} is older than 90 days.")
                            # try: 
                            #     # Create a new access key
                            #     new_key_response = iam_client.create_access_key(UserName=user_name)
                            #     new_access_key_id = new_key_response['AccessKey']['AccessKeyId']
                            #     new_secret_access_key = new_key_response['AccessKey']['SecretAccessKey']
                            #     print(f"Created new access key {new_access_key_id} for user {user_name}.")

                            #     # Store the new access key in the account's Secrets manager
                            #     secret_name = f"{user_name}-access-key"
                            #     secret_value = {
                            #         'AccessKeyId': new_access_key_id,
                            #         'SecretAccessKey': new_secret_access_key
                            #     }

                            #     # Store or update the secret in secrets manager
                            #     try:
                            #         # Check if the secret already exists
                            #         secrets_manager_client.describe_secret(SecretId=secret_name)

                            #         # Update the existing secret
                            #         secrets_manager_client.put_secret_value(
                            #             SecretId=secret_name,
                            #             SecretString=json.dumps(secret_value)
                            #         )
                            #         print(f"Updated secret for IAM user {user_name} in account {account.account_name}'s Secrets Manager.")
                            #     except secrets_manager_client.exceptions.ResourceNotFoundException:
                            #         # Create a new secret if it doesn't exist
                            #         secrets_manager_client.create_secret(
                            #             Name=secret_name,
                            #             SecretString=json.dumps(secret_value)
                            #         )
                            #         print(f"Created secret for IAM user {user_name} in account {account.account_name}'s Secrets Manager.")

                            #     # Disable the old access key
                            #     iam_client.update_access_key(UserName=user_name, AccessKeyId=access_key_id, Status='Inactive')
                            #     print(f"Disabled old access key {access_key_id} for IAM user {user_name}.")

                        else: 
                            print(f"Access key {access_key_id} for user {user_name} in account {account.account_name} is within the 90-day rotation period.")

        except ClientError as ex:
                print(f"Error checking Access keys for user {user_name} in account {account.account_name}: {ex}")
        except Exception as e:
                print(f"Unexpected error checking Access keys for user {user_name} in {account.account_name}: {e}")


#CMD => rye run bespinctl accesskey access-key-rotation