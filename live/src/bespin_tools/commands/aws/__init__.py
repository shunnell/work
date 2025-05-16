from __future__ import annotations

import click

from .guardduty import guardduty
from .iam import iam
from .organization import organization
from .security_reporting import security_reporting
from .vpc import vpc
from .eks import eks

from bespin_tools.lib.aws.organization import Organization

@click.group()
def aws():
    Organization.start_priming_common_client_cache()

aws.add_command(eks)
aws.add_command(organization)
aws.add_command(guardduty)
aws.add_command(iam)
aws.add_command(security_reporting)
aws.add_command(vpc)
