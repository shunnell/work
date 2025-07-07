from __future__ import annotations

import json
from collections import defaultdict
from csv import DictWriter

import click

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.arguments import AwsAccounts, AwsAccount
from bespin_tools.lib.aws.ecr import ECRRepository, ECRVulnerabilities
from bespin_tools.lib.aws.ecr.vulnerabilities import cache_repo_vulnerabilities_parallel
from bespin_tools.lib.logging import warn, error, info
from bespin_tools.lib.tables import BespinctlTable
from bespin_tools.lib.util import resolve_nonexistent

_REPORT_FIELDS = (
    'Repository',
    'Owner',
    'Deprecated',
    *(ECRVulnerabilities().to_report_dict().keys())
)

@click.group
def ecr():
    ...

def _repos(*accounts: Account):
    for account in accounts:
        yield from ECRRepository.all_repositories(account)


@ecr.command
@click.option('--account', default="381492150796", type=AwsAccount())
@click.option("--execute", is_flag=True, default=False)
def propagate_creation_template_policies(account: Account, execute: bool):
    prefix = "changing repo config" if execute else "would have changed repo config (pass --execute to update)"
    for repo in _repos(account):
        template = repo.creation_template
        if template is None:
            warn(f"{repo.name} has no template; may be grandfathered")
            continue
        propagators = [
            (repo.lifecycle_policy, template.lifecycle_policy, repo.client.put_lifecycle_policy, 'lifecyclePolicyText'),
            (repo.permissions_policy, template.permissions_policy, repo.client.set_repository_policy, 'policyText'),
            (repo.tag_mutability, template.tag_mutability, repo.client.put_image_tag_mutability, 'imageTagMutability'),
        ]
        for found, expected, updater, field in propagators:
            if found != expected:
                warn(f"{repo.name}: {prefix} mismatched {field}\n\nexpected: {type(expected)} {expected}\n\nfound: {type(found)} {found}")
                if execute:
                    if not isinstance(expected, (bytes, str, int)):
                        expected = json.dumps(expected, sort_keys=True)
                    updater(**{'repositoryName': repo.name, 'registryId': repo.registry, field: expected})

        if repo.encryption_configuration != template.encryption_configuration:
            error(f"{repo.name}: (must be fixed manually) mismatched encryption config:\n\tfound:\n\t{repo.encryption_configuration}\n\texpected:\n\t{template.encryption_configuration}")

@ecr.command
@click.option('--account', default="381492150796", type=AwsAccount())
@click.option('--tenant', default="all")
@click.option("--execute", is_flag=True, default=False)
def delete_pull_through_images(account: Account, tenant: str, execute: bool):
    """
    Lists (and optionally deletes) all ECR repositories that were created via pull-through cache.

    Whether or not an image was created via pull-through is based on what pullthrough rules currently exist.
    """
    prefix = "Deleting images in" if execute else "Would have deleted (pass --execute to delete) images in"
    deleted = 0
    for repo in _repos(account):
        if tenant == 'all' or repo.owner == tenant:
            if uri := repo.pull_through_source_uri:
                click.echo("{}: {} {} (pulled through from {})".format(repo.account, prefix, repo.name, uri))
                deleted += 1
                if execute:
                    repo.client.delete_repository(
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
    sample_result = {'Pulled Through': 0, 'Properly Named': 0, 'Improperly Named': 0}
    results = defaultdict(sample_result.copy)

    for repo in _repos(*accounts):
        result = results[repo.account]
        if repo.pull_through_source_uri is not None:
            result['Pulled Through'] += 1
        elif repo.is_properly_named:
            result['Properly Named'] += 1
        else:
            result['Improperly Named'] += 1

    with BespinctlTable(['Account', *sample_result.keys()]) as table:
        for account, result in results.items():
            if sum(result.values()) > 0:
                table.add_row(account, *result.values())

def _vuln_report_row(repo: ECRRepository, owner: str, deprecated: bool):
    row = dict.fromkeys(_REPORT_FIELDS)
    row['Repository'] = repo.name
    row['Owner'] = owner
    row['Deprecated'] = str(deprecated)
    row.update(repo.vulnerabilities.to_report_dict())
    return row

@ecr.command
@click.option('--account', default="381492150796", type=AwsAccount())
@click.option('--parallel', type=int, default=5)
@click.option('--file', type=click.Path(writable=True), required=True)
def vulnerability_report(account: Account, parallel: int, file: str):
    file = resolve_nonexistent(file)
    repos = tuple(_repos(account))
    with open(file, 'w', newline='') as csvfile:
        writer = DictWriter(csvfile, fieldnames=_REPORT_FIELDS)
        writer.writeheader()
        for repo in cache_repo_vulnerabilities_parallel(parallel, repos):
            row = _vuln_report_row(repo, repo.owner, repo.grandfathered)
            writer.writerow(row)
            csvfile.flush()

    info(f"Wrote report for {len(repos)} repos to '{file}'")
