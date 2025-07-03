from __future__ import annotations

import json
from functools import cached_property, partial
from typing import Literal, Sequence, Iterable

import lazy_object_proxy
from botocore.exceptions import ClientError

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.role_credentials import SSORoleCredentials
from bespin_tools.lib.aws.sso import new_sso_token
from bespin_tools.lib.aws.util import paginate, is_account_id, ClientGetter, DEFAULT_REGION
from bespin_tools.lib.cache import organization_schema_cache, sso_credentials_cache, update_cache_filehandle
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.logging import success, warn, error

class CloudCityAccountLookupError(BespinctlError):
    def show(self, **_) -> None:
        super().show()
        error(f"If you believe this failure to be in error, 'bespinctl clear-caches' and try again")


class _Organization(ClientGetter):
    """
    This object manages three responsibilities:
    1. Providing aws.Account handles for interactions with specific account/role pairs in Bespin's AWS Organization
        (including the org master account).
    2. Validating requests for account handles to ensure that, once provided, they're valid and credentialed (e.g. using
        a role the invoking user has, and with a temporary session token that will work) for doing things against the
        requested account(s).
    3. Caching account layout information (what accounts, roles, and regions exist in the organization) on the
        filesystem so that every user action doesn't require the time-consuming enumeration of all accounts to validate
        access.
    """
    ALL = Literal[b' \0 ']
    _CLIENTS_USED = ('sso', 'account', 'sts', 'sso-oidc')

    # In a cached property rather than set in the constructor so that start_priming_common_client_cache doesn't need to
    # do SSO.
    @cached_property
    def accounts(self) -> Sequence[dict]:
        with organization_schema_cache() as cachefh:
            try:
                cache_data = json.load(cachefh)
                CloudCityAccountLookupError.invariant(
                    isinstance(cache_data, dict),
                    f"cached JSON at '{cachefh.name}' is not a dict: {cache_data}",
                )
                CloudCityAccountLookupError.invariant(
                    len(cache_data.get('accounts', ())) > 0,
                    f"cached JSON at '{cachefh.name}' does not have 'accounts' key: {cache_data}",
                )
            except (json.JSONDecodeError, CloudCityAccountLookupError) as ex:
                cache_data = update_cache_filehandle(cachefh, self._load_aws_data,f"Updating account/role cache due to {ex}")
        return cache_data['accounts']

    def start_priming_common_client_cache(self):
        """
        Get a head start on creating some clients, since they take several seconds of compile time in some cases.
        The savings here is from the *act of setting up boto3's internals on the local machine*, not from saving time on
        I/O to AWS APIs. Boto3 is just a weird Python module with a noticeably high import-time cost, so we try to pay
        that in the background if we can.
        """
        for client_type in self._CLIENTS_USED:
            self._get_client(client_type, region_name=DEFAULT_REGION)

    def get_accounts(self, *identifiers: ALL | str | Account, sso_role=None) -> Iterable[Account]:
        if 'all' in identifiers:
            identifiers = (self.ALL,)
        identifiers = sorted(set(i.account_id if isinstance(i, Account) else i for i in identifiers))
        CloudCityAccountLookupError.invariant(len(identifiers) > 0, "No account IDs provided for lookup")
        CloudCityAccountLookupError.invariant(
            not isinstance(identifiers, str),
            f"Invalid account identifiers provided: {type(identifiers)} '{identifiers}'",
        )
        accounts = dict()
        if self.ALL in identifiers:
            accounts = {a['accountId']: a for a in self.accounts}
        else:
            for identifier in identifiers:  # Dedup and sort for deterministic error messages
                CloudCityAccountLookupError.invariant(
                    isinstance(identifier, str) and len(identifier) > 0 and identifier.strip() == identifier,
                    f"Invalid account filter: {type(identifier)} '{identifier}'"
                )
                identifier = str(identifier)  # Satisfy typecheckers for below lines
                if is_account_id(identifier):
                    retrieved_account = self._get_account(account_id=identifier)
                else:
                    retrieved_account = self._get_account(account_identifier=identifier)
                accounts[retrieved_account['accountId']] = retrieved_account
        for account in accounts.values():
            CloudCityAccountLookupError.invariant(
                sso_role is None or sso_role in account['roles'],
                f"Role '{sso_role}' not available for account: {account}"
            )
        for account_id in sorted(accounts.keys()):
            account = accounts[account_id]
            yield Account(
                account_id=account_id,
                account_name=account['accountName'],
                role_credentials=SSORoleCredentials(
                    client=self.sso_client(),
                    account=account_id,
                    role=account['roles'][0] if sso_role is None else sso_role,
                    token=self._sso_token,
                )
            )

    @cached_property
    def _sso_token(self):
        cache_updater = partial(new_sso_token, self.sso_oidc_client())
        with sso_credentials_cache() as fh:
            cache_bust_reason = None
            try:
                token = json.load(fh)
                success(f"Loaded bootstrap credentials from {fh.name}")
                # Just using this to probe whether our token works, validity doesn't matter:
                self.sso_client().list_account_roles(accessToken=token, accountId='fake')
            except json.JSONDecodeError:
                cache_bust_reason = "no saved SSO bootstrap token found"
            except ClientError as ex:
                ex_str = str(ex).lower()
                # Can't import the class since it's generated via spooky metaprogramming:
                if ex.__class__.__name__.endswith(
                        'UnauthorizedException') and 'session token not found or invalid' in ex_str:
                    cache_bust_reason = "saved SSO bootstrap token is invalid"
                # Raised due to nonexistent role for validity probe.
                elif not (ex.__class__.__name__.endswith(
                        'InvalidRequestException') and 'accountid supplied is not valid' in ex_str):
                    raise
            if cache_bust_reason is not None:
                token = update_cache_filehandle(fh, cache_updater, cache_bust_reason)
            return token

    def _get_account(self, *, account_id: str | None=None, account_identifier: str | None=None):
        CloudCityAccountLookupError.invariant(
            (account_id is None) != (account_identifier is None),
            "One and only one of account_id and account_identifier must be set"
        )
        if account_identifier is not None:
            matches = [a for a in self.accounts if account_identifier.lower() == a['accountName'].lower()]
        else:
            matches = [a for a in self.accounts if a['accountId'] == account_id]

        CloudCityAccountLookupError.invariant(
            len(matches) <= 1,
            f"Multiple matches returned (identifier={account_identifier}, id={account_id}): {matches}"
        )

        if len(matches) == 0:
            CloudCityAccountLookupError.invariant(len(self.accounts) > 0, "no account data could be retrieved from SSO")
            info = '\n\t'.join(f'{a["accountName"]} ({a["accountId"]}; {a["roles"]})' for a in self.accounts)
            if account_identifier is None:
                desc = f'account ID {account_id}'
            else:
                desc = f'account name {account_identifier}'
            raise CloudCityAccountLookupError(f'No AWS account found for {desc}. Available accounts:\n{info}')
        return matches[0]

    def _get_roles(self, account_id: str, account_name: str):
        roles = sorted(role['roleName'] for role in paginate(
            self.sso_client().list_account_roles,
            accessToken=self._sso_token,
            accountId=str(account_id),
        ))
        CloudCityAccountLookupError.invariant(len(roles) > 0, f"No roles found for account '{account_name}' ({account_id})")
        if len(roles) > 1:
            warn(f"multiple roles found for '{account_name}' ({account_id}), using the first one ({roles[0]}), but that may be wrong.")
            warn(f"This tool doesn't support multiple roles yet. Found roles: {roles}")
            # TODO multirole
        # return [roles[-1]]
        return roles

    def _load_aws_data(self) -> dict:
        # Region is immaterial here ... hopefully.
        rv = []
        for account in paginate(self.sso_client().list_accounts, accessToken=self._sso_token):
            account['roles'] = self._get_roles(account['accountId'], account['accountName'])
            rv.append(account)
        return {'accounts': rv}


# Singleton, since it maintains caches and many things refer to it by the old/class-like name. That can be refactored
# if deemed necessary:
Organization: _Organization = lazy_object_proxy.Proxy(_Organization)
