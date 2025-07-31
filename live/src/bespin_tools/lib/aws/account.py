from __future__ import annotations

from functools import cached_property

import attr

from bespin_tools.lib.aws.role_credentials import STSRoleCredentials, SSORoleCredentials
from bespin_tools.lib.aws.util import paginate, ClientGetter, DEFAULT_REGION
from bespin_tools.lib.command.environment import EnvironmentVariables


@attr.define(kw_only=True, frozen=True, order=True)
class Account(ClientGetter):
    account_id: str = attr.field(validator=attr.validators.min_len(1))
    account_name: str = attr.field(validator=attr.validators.min_len(1), order=False)
    _role_credentials: SSORoleCredentials = attr.field(order=False, repr=False, hash=False)
    region: str = attr.field(validator=attr.validators.min_len(1), default=DEFAULT_REGION)

    def __str__(self):
        if self.region == DEFAULT_REGION:
            return f"{self.account_name} ({self.account_id})"
        return f"{self.account_name} ({self.account_id}:{self.region})"

    def environment_variables(self, region_name: str=None, **assume_role_kwargs) -> EnvironmentVariables:
        region = self.region if region_name is None else region_name
        env = EnvironmentVariables(str(self))
        env.update({
            'AWS_DEFAULT_REGION': region,
            'DOS_CLOUD_CITY_ACCOUNT_ID': self.account_id,
            'DOS_CLOUD_CITY_ACCOUNT_NAME': self.account_name,
            **self._creds(**assume_role_kwargs).environment_kwargs()
        })
        return env

    def _creds(self, role=None, session_name=None, external_id=None):
        if role is session_name is external_id is None:
            return self._role_credentials
        else:
            return STSRoleCredentials(
                client=self.sts_client(),
                account=self.account_id,
                role=role,
                session_name=session_name,
                external_id=external_id,
            )

    def _get_client(self, kind: str, role=None, session_name=None, external_id=None, **kwargs):
        region = kwargs.pop('region_name', self.region)
        return super()._get_client(
            kind,
            region_name=region,
            **self._creds(role=role, session_name=session_name, external_id=external_id).client_kwargs(),
            **kwargs,
        )

    @cached_property
    def regions(self):
        us_regions, other_regions = [], []
        for region in paginate(self.account_client().list_regions):
            if region['RegionOptStatus'].startswith('ENABL'):
                region = region['RegionName']
                (us_regions if region.startswith('us') else other_regions).append(region)

        # Put US regions first, and put the default region at the head if it's present:
        us_regions.sort()
        other_regions.sort()
        rv = us_regions + other_regions
        try:
            rv.remove(DEFAULT_REGION)
            rv = [DEFAULT_REGION] + rv
        except ValueError:
            pass
        return rv
