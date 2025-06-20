from __future__ import annotations

import click

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.arguments import AwsAccounts
from bespin_tools.lib.aws.ecr import ECRRepository
from bespin_tools.lib.tables import BespinctlTable


@click.group
def ecr():
    ...

@ecr.command
@click.option('--accounts', default="381492150796", type=AwsAccounts())
@click.option("--execute", is_flag=True, default=False)
def delete_pull_through_images(accounts: tuple[Account, ...], execute: bool):
    """
    Lists (and optionally deletes) all ECR repositories that were created via pull-through cache.

    Whether or not an image was created via pull-through is based on what pullthrough rules currently exist.
    """
    prefix = "Deleting images in" if execute else "Would have deleted (pass --execute to delete) images in"
    deleted = 0
    for account in accounts:
        for repo in ECRRepository.all_repositories(account):
            if uri := repo.pull_through_source_uri:
                click.echo("{}: {} {} (pulled through from {})".format(account, prefix, repo.name, uri))
                deleted += 1
                if execute:
                    account.ecr_client().delete_repository(
                        repositoryName=repo.name,
                        registryId=repo.registry,
                        force=True,
                    )
    click.echo(f"{'Deleted' if execute else 'Would have deleted'} {deleted} ECR repositories")

@ecr.command
@click.option('--accounts', default="all", type=AwsAccounts())
def repository_counts(accounts: tuple[Account, ...]):
    """
    Lists repositories in each account's ECR registries.

    Images are counted by whether they were created via pull-through caching, and if not, whether they are properly
    named (e.g. :repository/cloud-city/tenant-name/something...) or use a legacy/improper path naming scheme.

    Accounts with no ECR repositories are omitted.
    """
    with BespinctlTable(['Account', 'Pulled Through', 'Properly Named', 'Improperly Named']) as table:
        for account in accounts:
            pulled_through, properly_named, improperly_named = 0, 0, 0
            for repo in ECRRepository.all_repositories(account):
                if repo.pull_through_source_uri is not None:
                    pulled_through += 1
                elif repo.is_properly_named:
                    properly_named += 1
                else:
                    improperly_named += 1
            if pulled_through + properly_named + improperly_named > 0:
                table.add_row(account, pulled_through, properly_named, improperly_named)