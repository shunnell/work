from __future__ import annotations

import click

from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.tables import BespinctlTable


def _certs():
    for account in Organization.get_accounts(Organization.ALL):
        client = account.acm_client()
        for cert in paginate(client.list_certificates):
            yield account, client.describe_certificate(CertificateArn=cert['CertificateArn'])['Certificate']


@click.group
def acm():
    ...

@acm.command()
def list_certificates():
    with BespinctlTable(['Account', 'Domain', 'Status', 'ARN', 'CA']) as table:
        for account, cert in _certs():
            names = set(cert['SubjectAlternativeNames'])
            names.add(cert['DomainName'])
            ca = cert.get('CertificateAuthorityArn')
            if ca is not None:
                *_, region, account, name = ca.split(':')
                ca = ':'.join((region, account, name))
            cert_name = cert['CertificateArn'].rsplit(':', 1)[-1]
            table.add_row(
                account,
                ",".join(sorted(names)),
                cert['Status'],
                cert_name,
                ca,
            )
