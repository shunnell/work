###################### 45DaysUnusedCredentials ######################################################################
# ██╗  ██╗███████╗      ██████╗  █████╗ ██╗   ██╗███████╗      ██╗   ██╗███╗   ██╗██╗   ██╗███████╗███████╗██████╗  #
# ██║  ██║██╔════╝      ██╔══██╗██╔══██╗╚██╗ ██╔╝██╔════╝      ██║   ██║████╗  ██║██║   ██║██╔════╝██╔════╝██╔══██╗ #
# ███████║███████╗█████╗██║  ██║███████║ ╚████╔╝ ███████╗█████╗██║   ██║██╔██╗ ██║██║   ██║███████╗█████╗  ██║  ██║ #
# ╚════██║╚════██║╚════╝██║  ██║██╔══██║  ╚██╔╝  ╚════██║╚════╝██║   ██║██║╚██╗██║██║   ██║╚════██║██╔══╝  ██║  ██║ #
#      ██║███████║      ██████╔╝██║  ██║   ██║   ███████║      ╚██████╔╝██║ ╚████║╚██████╔╝███████║███████╗██████╔╝ #
#      ╚═╝╚══════╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝       ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝╚═════╝  #
#                                                                                                                   #
#  ██████╗██████╗ ███████╗██████╗ ███████╗███╗   ██╗████████╗██╗ █████╗ ██╗     ███████╗                            #
# ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔════╝████╗  ██║╚══██╔══╝██║██╔══██╗██║     ██╔════╝                            #
# ██║     ██████╔╝█████╗  ██║  ██║█████╗  ██╔██╗ ██║   ██║   ██║███████║██║     ███████╗                            #
# ██║     ██╔══██╗██╔══╝  ██║  ██║██╔══╝  ██║╚██╗██║   ██║   ██║██╔══██║██║     ╚════██║                            #
# ╚██████╗██║  ██║███████╗██████╔╝███████╗██║ ╚████║   ██║   ██║██║  ██║███████╗███████║                            #
#  ╚═════╝╚═╝  ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝                            #
###################### 45DaysUnusedCredentials ######################################################################
import click
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError
from bespin_tools.lib.aws.sso import sso_and_account_list
from bespin_tools.lib.aws.util import paginate

@click.group()
def users():
    """ Group for AWS-related commands """
    pass

@users.command()
def list_unused_credentials():
    """
    List IAM user credentials across all accounts and regions.
    """
    # Get the current UTC time
    utc_now = datetime.utcnow().replace(tzinfo=timezone.utc)
    # Set the inactivity threshold (45days)
    inactivity_threshold = utc_now - timedelta(days=45)
    # Get all accounts using SSO (this handles account list and session handling)
    for account in sso_and_account_list('us-east-1'):  # Assuming `sso_and_account_list` manages SSO
        print(f"\n--- Processing Account: Account_ID= ({account.account_id}) Account_Name= ({account.account_name}) ---\n")
    
        try:
                # Use the `account.client` for the iam client
                iam_client = account.client('iam')
                # List all iam users in the account
                users = list(paginate(iam_client, 'list_users', 'Users'))
                for user in users:
                    user_name = user['UserName']
                    # List access keys for each user
                    access_keys = list(paginate(iam_client, 'list_access_keys', 'AccessKeyMetadata', UserName=user_name))

                    for key in access_keys:
                        access_key_id = key['AccessKeyId']
                        create_date = key['CreateDate']

                        # Check when the access key was last used
                        last_used_response = iam_client.get_access_key_last_used(AccessKeyId=access_key_id)
                        last_used_date = last_used_response.get('AccessKeyLastUsed', {}).get('LastUsedDate', create_date)

                        if last_used_date <= inactivity_threshold:
                            print(f"access key {access_key_id} for user {user_name} in account {account.account_name} is inactive for 45 days or more.")
                            # iam_client.update_access_key(UserName=user_name, AccessKeyId=access_key_id, Status='Inactive')

                        else: 
                            print(f"Access key {access_key_id} for user {user_name} in account {account.account_name} is active within the last 45 days.")

        except ClientError as ex:
                print(f"Error checking Access keys for user {user_name} in account {account}: {ex}")
        except Exception as e:
                print(f"Unexpected error checking Access keys for user {user_name} in {account}: {e}")


# CMD ==> rye run bespinctl users list-unused-credentials