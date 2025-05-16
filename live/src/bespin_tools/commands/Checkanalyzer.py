####### GET STATUS REPORT OF THE ANALYZER IN ALL ACCOUNTS ##########
#  █████╗ ███╗   ██╗ █████╗ ██╗  ██╗   ██╗███████╗███████╗██████╗  #
# ██╔══██╗████╗  ██║██╔══██╗██║  ╚██╗ ██╔╝╚══███╔╝██╔════╝██╔══██╗ #
# ███████║██╔██╗ ██║███████║██║   ╚████╔╝   ███╔╝ █████╗  ██████╔╝ #
# ██╔══██║██║╚██╗██║██╔══██║██║    ╚██╔╝   ███╔╝  ██╔══╝  ██╔══██╗ #
# ██║  ██║██║ ╚████║██║  ██║███████╗██║   ███████╗███████╗██║  ██║ #
# ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝ #
####### GET STATUS REPORT OF THE ANALYZER IN ALL ACCOUNTS ##########
import click
from botocore.exceptions import ClientError
from bespin_tools.lib.aws.sso import sso_and_account_list
from bespin_tools.lib.aws.util import paginate

@click.group()
def analyzer():
    """ Group for AWS-related commands """
    pass

@analyzer.command()
def list_access_analyzer():
    """
    List IAM Access Analyzer across all accounts and regions.
    """
    # Get all accounts using SSO (this handles account list and session handling)
    for account in sso_and_account_list('us-east-1'):  # Assuming `sso_and_account_list` manages SSO
        print(f"\n--- Processing Account: Account_ID= ({account.account_id}) Account_Name= ({account.account_name}) ---\n")
        # Use the `account.client` to create the accessanalyzer client for the account
        account_client = account.client('accessanalyzer', region_name='us-east-1')  # Assuming `account.client` works
        # Loop through all available regions in each account 
        for region in account.regions:
            try:
                # print(f"Enabling Access Analyzer in region: {region}")
                # Use the `account.client` for the region-specific analyzer client
                analyzer_client = account.client('accessanalyzer', region_name=region)
                # Check if an analyzer already exists in the region
                existing_analyzers = list(paginate(analyzer_client, 'list_analyzers', 'analyzers', type="ACCOUNT"))

                if not existing_analyzers:
                    # Create a new Access Analyzer if none exist
                    # analyzer_name = f"{account.name}-access-analyzer"
                    # analyzer_client.create_analyzer(analyzerName=analyzer_name, type="ACCOUNT")
                    # print(f"Access Analyzer '{analyzer_name}' created in region: {region}")
                    print(f"Access Analyzer not exists in region: {region}")
                else:
                    print(f"Access Analyzer already exists in region: {region}")
            except ClientError as ex:
                print(f"Error enabling Access Analyzer in account {account}, region {region}: {ex}")
            except Exception as e:
                print(f"Unexpected error enabling Access Analyzer in {account}, {region}: {e}")


# rye run bespinctl analyzer list-access-analyzer


