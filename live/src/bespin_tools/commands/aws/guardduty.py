from __future__ import annotations

import click

from bespin_tools.lib.aws import CLOUD_CITY_ORGANIZATION_ROOT_ACCOUNT
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.errors import BespinctlError


@click.group()
@click.pass_context
def guardduty(ctx):
    accounts = {a.account_id: a for a in Organization.get_accounts(Organization.ALL)}
    root = accounts.pop(CLOUD_CITY_ORGANIZATION_ROOT_ACCOUNT)
    gdc = root.guard_duty_client()
    root_detector, = paginate(gdc.list_detectors)
    ctx.obj = (gdc, root_detector, accounts)


def get_status(k: str, v: dict):
    if k == 'Kubernetes':
        return f'{k}.AuditLogs', v['AuditLogs']['Status'].title()
    elif k == 'MalwareProtection':
        return f'{k}.EC2EbsScanning', v['ScanEc2InstanceWithFindings']['EbsVolumes']['Status'].title()
    else:
        return k, v['Status'].title()

class GuardDutyStatus(dict):
    def __setitem__(self, key, value):
        BespinctlError.invariant(isinstance(value, str), f"Invalid value: {type(value)} {value}")
        BespinctlError.invariant(isinstance(key, str), f"Invalid key: {type(key)} {key}")
        value = value.title()
        BespinctlError.invariant(value in ('Enabled', 'Disabled'), f"Invalid enabled status: {type(value)} {value}")
        key = ''.join(c.upper() for c in key if c != '_')
        # I *think* the EksRuntimeMonitoring config is deprecated and always reports "Disabled", and instead EKS status
        # is indicated by a combination of "RuntimeMonitoring" being enabled at the top level + the
        # AdditionalConfiguration for RuntimeMonitoring saying that EKS agent auto-configuration is configured + EKS
        # audit log analysis. But I'm not sure; will ask Nazir/AWS TAM at some point.
        if not key.startswith('EKSRUNTIMEMONITORING'):
            return super().__setitem__(key, value)

@guardduty.command()
@click.pass_obj
def status_by_account(resources):
    gdc, detector, accounts = resources
    root_config = gdc.get_member_detectors(DetectorId=detector, AccountIds=list(accounts.keys()))
    unprocessed_accounts = root_config.get('UnprocessedAccounts', [])
    BespinctlError.invariant(len(unprocessed_accounts) == 0, f"Some accounts are still processing: {unprocessed_accounts}")
    for data in root_config['MemberDataSourceConfigurations']:
        results = GuardDutyStatus()
        for k, v in data['DataSources'].items():
            k, v = get_status(k, v)
            results[k] = v
        for feature in data['Features']:
            results[feature['Name']] = feature['Status'].title()
            for substatus in feature.get('AdditionalConfiguration', ()):
                results[f'{feature["Name"]}.{substatus["Name"]}'] = substatus['Status'].title()
        account = accounts[data['AccountId']]
        for k, v in results.items():
            print(f"Account {account.account_id} ('{account.account_name}')\t\t", k, v)
