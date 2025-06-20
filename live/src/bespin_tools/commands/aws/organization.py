from __future__ import annotations

import click
from botocore.exceptions import ClientError

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.command.external import ExternalCommand
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.logging import info
from bespin_tools.lib.tables import BespinctlTable


@click.group()
@click.option('--account', multiple=True, default=[])
@click.option('--role', default=None)
@click.pass_context
def organization(ctx, account, role):
    account = sorted(set(account))
    if len(account) == 0 or 'all' in account:
        account = [Organization.ALL]
    accounts = Organization.get_accounts(*account, sso_role=role)
    ctx.obj = sorted(accounts)
    if len(ctx.obj) == 0:
        raise click.ClickException('No accounts selected')

@organization.command()
@click.pass_obj
@click.option('--terse', is_flag=True, default=False)
def list_accounts(accounts: list[Account], terse: bool):
    if terse:
        click.echo('\n'.join(a.account_id for a in accounts))
        return
    with BespinctlTable(['Account ID', 'Account name', 'Enabled regions']) as table:
        for account in accounts:
            table.add_row(account.account_id, account.account_name, ', '.join(account.regions))

@organization.command()
@click.pass_obj
def aws_config_status_by_region(accounts: list[Account]):
    for account in accounts:
        info(f'Account {account.account_id}: "{account.account_name}"')
        for region in account.regions:
            config = account.config_client(region_name=region)
            try:
                recorders = list(paginate(config.list_configuration_recorders))
                if len(recorders):
                    recorders = f'yes ({len(recorders)})'
                else:
                    recorders = 'no (no config resources in region)'
            except ClientError as ex:
                if 'InternalFailure' not in str(ex):
                    raise
                recorders = 'no (region disabled)'
            info(f"\t{region: <20}:{recorders: >40}")


def _eks_clusters(accounts: list[Account]):
    for account in accounts:
        for region in account.regions:
            eks = account.eks_client(region_name=region)
            for cluster in sorted(paginate(eks.list_clusters)):
                yield account, region, cluster

@organization.command(name='run-command')
@click.argument('args', nargs=-1, type=click.UNPROCESSED)
@click.pass_obj
def run_command(accounts: list[Account], args):
    for account in accounts:
        cmd = ExternalCommand(args[0])
        # TODO better logger output (account, cmd, args)
        cmd.env.update(account.environment_variables())  # TODO role support
        cmd.run(*args[1:])

@organization.command()
@click.option('--assume-role-arn', default=None)
@click.pass_obj
def shell_credentials(accounts: list[Account], assume_role_arn):
    BespinctlError.invariant(
        len(accounts) == 1,
        f"Only one account is allowed; got multiple ('run-commands', plural, can be used to iterate accounts). Retrieved accounts: {accounts}"
    )
    environment = accounts[0].environment_variables(assume_role=assume_role_arn)
    for line in environment.as_shell_commands():
        info(line)

@organization.command()
@click.pass_obj
def list_eks_clusters(accounts: list[Account]):
    for account, region, cluster in _eks_clusters(accounts):
        info(f"{account} {region} {cluster}")
