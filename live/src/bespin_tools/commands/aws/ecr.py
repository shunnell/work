from __future__ import annotations

import json
import os
from collections import defaultdict
from csv import DictWriter
from typing import Collection

import click

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.arguments import AwsAccounts, AwsAccount, TenantName
from bespin_tools.lib.aws.ecr import ECRRepository, ECRVulnerabilities
from bespin_tools.lib.aws.ecr.vulnerabilities import cache_repo_vulnerabilities_parallel
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.logging import warn, error, info
from bespin_tools.lib.tables import BespinctlTable
from bespin_tools.lib.util import resolve_nonexistent

_REPORT_FIELDS = (
    'Repository',
    'Owner',
    'Deprecated',
    *sorted(ECRVulnerabilities().to_report_dict().keys())
)

@click.group
def ecr():
    ...

def _repos(accounts: Account | Collection[Account], tenant: str='all', ignore_no_repos=False):
    if isinstance(accounts, Account):
        accounts = [accounts]
    for account in accounts:
        for repo in ECRRepository.all_repositories(account):
            if tenant == 'all' or repo.owner == tenant:
                ignore_no_repos = True
                yield repo
    BespinctlError.invariant(ignore_no_repos, f"No repos found in accounts {accounts} for tenant '{tenant}'")


@ecr.command
@click.option('--account', default="381492150796", type=AwsAccount())
@click.option('--tenant', default="all", type=TenantName())
@click.option("--execute", is_flag=True, default=False)
def propagate_creation_template_policies(account: Account, tenant: str, execute: bool):
    prefix = "changing repo config" if execute else "would have changed repo config (pass --execute to update)"
    for repo in _repos(account, tenant):
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
@click.option('--tenant', default="all", type=TenantName())
@click.option("--execute", is_flag=True, default=False)
def delete_pull_through_images(account: Account, tenant: str, execute: bool):
    """
    Lists (and optionally deletes) all ECR repositories that were created via pull-through cache.

    Whether or not an image was created via pull-through is based on what pullthrough rules currently exist.
    """
    prefix = "Deleting images in" if execute else "Would have deleted (pass --execute to delete) images in"
    deleted = 0
    for repo in _repos(account, tenant):
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

    for repo in _repos(accounts, ignore_no_repos=True):
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
@click.option('--parallel', type=int, default=8)
@click.option('--file', type=click.Path(writable=True))
@click.option('--tenant', default="all", type=TenantName())
def vulnerability_report(account: Account, parallel: int, file: str | None, tenant: str):
    file = os.devnull if file is None else resolve_nonexistent(file)
    repos = tuple(_repos(account, tenant))

    rows = []
    totals = ECRVulnerabilities().to_report_dict()
    for repo in cache_repo_vulnerabilities_parallel(parallel, repos):
        rows.append(_vuln_report_row(repo, repo.owner, repo.grandfathered))
        for k, v in rows[-1].items():
            if k in totals:
                totals[k] += v
    rows.sort(key=lambda r: (r['Owner'], r['Deprecated'], r['Repository']))
    with open(file, 'w', newline='') as csvfile, BespinctlTable(_REPORT_FIELDS) as table:
        writer = DictWriter(csvfile, fieldnames=_REPORT_FIELDS)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)
            table.add_row(row)
    with BespinctlTable([f"Total: {k}" for k in totals.keys()]) as table:
        table.add_row(*totals.values())
    if file != os.devnull:
        info(f"Wrote report for {len(repos)} repos to '{file}'")
