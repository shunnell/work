from __future__ import annotations

import json
import operator
import sys

from yaml import safe_dump

from pprint import pprint

import click

from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.tables import BespinctlTable


@click.group
def eks():
    ...

def _clusters():
    for account in Organization.get_accounts(Organization.ALL):
        client = account.eks_client()
        for cluster_name in paginate(client.list_clusters):
            info = client.describe_cluster(name=cluster_name)["cluster"]
            addons = paginate(client.list_addons, clusterName=cluster_name)
            yield account, cluster_name, info["version"], info["platformVersion"], sorted(addons)

@eks.command
def list_clusters():
    with BespinctlTable(['Account', 'Cluster', 'Version', 'Platform Version', 'Addons']) as table:
        for account, cluster, version, platform_version, addons in _clusters():
            table.add_row(account, cluster, version, platform_version, ", ".join(addons))


@eks.command
@click.argument('addon')
@click.option('--all-versions', is_flag=True, default=False)
def describe_addon(addon: str, all_versions: bool):
    max_kube_version = ""
    seen_addons = set()
    for account, cluster, version, _, addons in _clusters():
        max_kube_version = max(max_kube_version, version)
        seen_addons.update(addons)
    if addon not in seen_addons:
        raise BespinctlError(f"Addon '{addon}' not found; available options:\n{'\n'.join(sorted(seen_addons))}")
    client = account.eks_client()
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
