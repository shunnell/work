from __future__ import annotations

import csv
from collections import defaultdict
from pathlib import Path
from pprint import pprint

import click

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import paginate


@click.group()
@click.option('--account', default='381492150796')
@click.option('--role', default=None)
@click.pass_context
def security_reporting(ctx, account: str, role:str):
    account, = Organization.get_accounts(account, sso_role=role)
    ctx.obj = account


def _finding_descriptions():
    p = Path(__file__)
    results = dict()
    with open(p.parent.joinpath('finding_descriptions.csv'),'r',  newline='') as csvfile:
        for finding_id, finding_description, current_state, remediation in csv.reader(csvfile):
            results[finding_id] = (finding_description, current_state, remediation)

    return results

def findings(client, inspector=False, **filters):
    filters = {k: [{'Value': v, 'Comparison': 'EQUALS'}] for k, v in filters.items()}
    filters['WorkflowStatus'] = [
        {'Value': 'NEW', 'Comparison': 'EQUALS'},
        {'Value': 'NOTIFIED', 'Comparison': 'EQUALS'}
    ]
    filters['SeverityLabel'] = [
        {'Value': 'INFORMATIONAL', 'Comparison': 'NOT_EQUALS'},
        {'Value': 'LOW', 'Comparison': 'NOT_EQUALS'}
    ]
    filters['ProductName'] = [
        {'Value': 'Inspector', 'Comparison': 'EQUALS' if inspector else 'NOT_EQUALS'}
    ]
    # TODO: This seems valuable
    # filters["ComplianceAssociatedStandardsId"] = [
    #     {
    #         "Value": "standards/nist-800-53/v/5.0.0",
    #         "Comparison": "EQUALS"
    #     }
    # ]

    for finding in paginate(client.get_findings, Filters=filters):
        if finding['ProductName'] == 'Inspector' and all(r['Type'] == 'AwsEcrContainerImage' for r in finding['Resources']):
            continue
        yield finding

@security_reporting.command()
@click.pass_obj
def sh(account: Account):
    output = 'compliance.csv'
    client = account.security_hub_client()

    resources_by_account_and_control = defaultdict(lambda: defaultdict(lambda: {'Resources': [], 'Severity': 'UNKNOWN'}))
    idx = 0
    for idx, finding in enumerate(findings(
        client,
        inspector=False,
        Region='us-east-1',
        RecordState='ACTIVE',
    )):
        try:
            sci = finding.get('Compliance', {}).get('SecurityControlId', None)
            account = finding['AwsAccountId']
            if sci is None:
                print("sci is none")
                continue
            resources_by_account_and_control[account][sci]['Severity'] = finding['Severity']['Label']
            resources_by_account_and_control[account][sci]['Requirements'] = finding.get('Compliance', {}).get('RelatedRequirements', [])
            for r in finding["Resources"]:
                resources_by_account_and_control[account][sci]['Resources'].append(f"{r['Type']} {r['Id']}")
        except Exception as e:
            pprint(e)
            pprint(finding)
            raise

    
    print("Assessed", idx, "findings:")
    descriptions = _finding_descriptions()
    accounts = Organization.get_accounts(Organization.ALL)
    name_by_id = {a.account_id: a.account_name for a in accounts}
    with open(output, 'w', newline='') as csvfile:
        fieldnames = ['Finding ID', 'Severity', 'Status', 'Count', 'Account', 'Finding Description', 'Triggering State', 'Remediation Plans (if not false)', 'Resources', 'NIST Controls']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for account, by_control in resources_by_account_and_control.items():
            for control, data in by_control.items():
                desc, state, remediation = descriptions.get(control, ["TODO", "TODO", "TODO"])
                writer.writerow({
                    'Account': f"{name_by_id.get(account, 'UNKNOWN')} ({account})",
                    'Finding ID': control,
                    'Severity': data['Severity'],
                    'Status': '',
                    'Count': str(len(data['Resources'])),
                    'Finding Description': desc,
                    'Triggering State': state,
                    'Remediation Plans (if not false)': remediation,
                    'Resources': '; '.join(data['Resources']),
                    'NIST Controls': ';'.join(data['Requirements'])
                })
                print(account, control)
                print("\n\t" + "\n\t".join([data['Severity'], desc, state, remediation, *data['Resources']]))
