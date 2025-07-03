from __future__ import annotations

import json
import operator
from typing import Iterable, Collection

import click
from yaml import safe_dump

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.arguments import AwsAccounts
from bespin_tools.lib.aws.eks import EksCluster
from bespin_tools.lib.aws.eks.kubeconfig import render_kubeconfig
from bespin_tools.lib.aws.eks.token import get_token_for_cluster
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.cache import isolated_kubernetes_files
from bespin_tools.lib.command.external import ExternalCommand
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.logging import info, debug, error
from bespin_tools.lib.tables import BespinctlTable
from bespin_tools.lib.util import resolve_nonexistent


@click.group
def eks():
    ...

def _clusters(accounts: Iterable[Account], clusters: str, raise_if_none_reachable=True) -> tuple[EksCluster, ...]:
    found_reachable = False
    suffix = "see 'bespinctl aws eks check-reachability' for more info"
    rv = []
    for idx, cluster in enumerate(EksCluster.from_argument(accounts, clusters)):
        rv.append(cluster)
        if cluster.reachable:
            found_reachable = True
        else:
            error(f"Cluster {cluster} is not reachable and will not be usable; {suffix}")
    BespinctlError.invariant(
        found_reachable or not raise_if_none_reachable,
        f"No reachable clusters found; {suffix}"
    )
    return tuple(rv)


@eks.command
def list_clusters():
    with BespinctlTable(['Account', 'Cluster', 'Reachable', 'Version', 'Platform Version', 'Addons']) as table:
        for cluster in _clusters(Organization.get_accounts('all'), 'all', raise_if_none_reachable=False):
            table.add_row(
                cluster.account,
                cluster.name,
                repr(cluster.reachable).removesuffix('()'),
                cluster["version"],
                cluster["platformVersion"],
                ", ".join(cluster.addons),
            )


@eks.command
@click.argument('addon')
@click.option('--all-versions', is_flag=True, default=False)
@click.option('--accounts', '--account', type=AwsAccounts(), required=True)
@click.option('--clusters', '--cluster', type=str, default='all')
def describe_addon(addon: str, all_versions: bool, accounts: Collection[Account], clusters: str):
    max_kube_version = ""
    seen_addons = set()
    for cluster in _clusters(accounts, clusters, raise_if_none_reachable=False):
        max_kube_version = max(max_kube_version, cluster["version"])
        seen_addons.update(cluster.addons)
        client = cluster.account.eks_client()

    if addon not in seen_addons:
        raise BespinctlError(f"Addon '{addon}' not found; available options:\n{'\n'.join(sorted(seen_addons))}")
    rv = []
    for addon_config in paginate(client.describe_addon_versions, kubernetesVersion=max_kube_version, addonName=addon):
        addon_config['kubernetesVersion'] = max_kube_version
        for details in addon_config.pop('addonVersions'):
            addon_config.update(details)
            addon_config.update(client.describe_addon_configuration(addonName=addon, addonVersion=details['addonVersion']))
            del addon_config['ResponseMetadata']
            addon_config['configurationSchema'] = json.loads(addon_config['configurationSchema'])
            rv.append(addon_config.copy())
    rv.sort(key=operator.itemgetter('addonVersion'), reverse=True)
    for addon in rv:
        click.echo(safe_dump(addon))
        if not all_versions:
            break

@eks.command
@click.option('--account', type=AwsAccounts(), required=True)
@click.option('--cluster', type=str, required=True)
@click.option('--bare', is_flag=True, default=False)
def get_token(account: Iterable[Account], cluster: str, bare: bool):
    """
    Retrieves an EKS authentication token for use in logging into a specified cluster.
    """
    account, = account
    # Handle ARNs as well as names:
    token = get_token_for_cluster(account, cluster.split(':cluster/')[-1])
    if bare:
        click.echo(token["status"]["token"])
    else:
        click.echo(json.dumps(token))

@eks.command
@click.option('--accounts', type=AwsAccounts(), required=True)
@click.option('--clusters', type=str, default='all')
@click.option('--file', type=click.Path(writable=True), required=True)
def generate_kubeconfig(accounts: Collection[Account], clusters: str, file: str):
    file = resolve_nonexistent(file)
    clusters = _clusters(accounts, clusters, raise_if_none_reachable=False)
    kubeconfig_data = safe_dump(render_kubeconfig(*clusters))
    info(f"Writing generated kubeconfig to {file}")
    file.write_text(kubeconfig_data)


@eks.command(name='run-command')
@click.option('--accounts', '--account', type=AwsAccounts(), required=True)
@click.option('--clusters', '--cluster', type=str, default='all')
@click.option('--each-cluster', is_flag=True, default=False)
@click.argument('args', nargs=-1, type=click.UNPROCESSED)
def run_command(accounts: Collection[Account], clusters: str, each_cluster: bool, args):
    command = ExternalCommand(args[0])
    clusters = _clusters(accounts, clusters)
    configs = map(render_kubeconfig, clusters) if each_cluster else [render_kubeconfig(*clusters)]
    for config in configs:
        with isolated_kubernetes_files() as (config_file, cache_dir):
            kubeconfig_data = safe_dump(config)
            debug(f"Writing generated kubeconfig to {config_file}")
            config_file.write_text(kubeconfig_data)
            command.env['KUBECONFIG'] = config_file
            command.env['KUBECACHEDIR'] = cache_dir
            command.run(*args[1:])
