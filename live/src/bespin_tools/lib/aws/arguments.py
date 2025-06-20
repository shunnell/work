from __future__ import annotations
from click import ParamType

from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import is_account_id


class AwsAccounts(ParamType):
    name = "AWS account IDs, comma-separated. Providing 'all' will use all account IDs in Cloud City."

    def convert(self, value, param, ctx):
        ids = {i.strip() for i in value.split(',')}
        ids.discard('')
        for item in sorted(ids):
            if item != 'all' and not is_account_id(item):
                self.fail(f"{item!r} is not a valid AWS account ID", param, ctx)
        if 'all' in ids:
            ids = Organization.ALL,
        return tuple(sorted(Organization.get_accounts(*ids)))
