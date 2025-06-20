from __future__ import annotations

import click

from bespin_tools.lib.aws.organization import Organization

@click.group()
def aws():
    Organization.start_priming_common_client_cache()
