from __future__ import annotations

from click import ParamType

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import is_account_id


class AwsAccounts(ParamType):
    name = "AWS account IDs, comma-separated. Providing 'all' will use all account IDs in Cloud City."

    def _get_ids(self, value, param, ctx) -> list[str]:
        ids = {i.strip() for i in value.split(",")}
        ids.discard("")
        for item in sorted(ids):
            if item != "all" and not is_account_id(item):
                self.fail(f"{item!r} is not a valid AWS account ID", param, ctx)
        if "all" in ids:
            ids = (Organization.ALL,)
        return sorted(ids)

    def _query_accounts(self, ids, param, ctx, max_length=float("inf")):
        accounts = tuple(sorted(Organization.get_accounts(*ids)))
        if len(accounts) > max_length:
            self.fail(
                f"Expected {max_length} account(s) but got {len(accounts)}: {', '.join(accounts)}",
                param,
                ctx,
            )
        if len(accounts) == 0:
            self.fail(f"AWS account(s) not found: {', '.join(ids)}", param, ctx)
        return accounts

    def convert(self, value, param, ctx) -> tuple[Account, ...]:
        if isinstance(value, str):
            ids = self._get_ids(value, param, ctx)
            return self._query_accounts(ids, param, ctx)
        elif not all(isinstance(i, Account) for i in value):
            self.fail(f"Expected a string, but got {type(value)} {value}")
        return value


class AwsAccount(AwsAccounts):
    name = "Single AWS account ID"

    def convert(self, value, param, ctx) -> Account:
        if isinstance(value, str):
            ids = self._get_ids(value, param, ctx)
            if len(ids) != 1 or Organization.ALL in ids:
                self.fail(
                    f"Single account required, but multiple accounts requested: {', '.join(ids)}",
                    param,
                    ctx,
                )
            return self._query_accounts(ids, param, ctx, max_length=1)[0]
        elif not isinstance(value, Account):
            self.fail(f"Expected a string, but got {type(value)} {value}")
        return value
