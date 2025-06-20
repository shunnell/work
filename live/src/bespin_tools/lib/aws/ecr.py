from __future__ import annotations

import re
from dataclasses import dataclass
from functools import cache

import attr
from arn import Arn

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.util import paginate


@cache
def _registry_settings(account: Account):
    client = account.ecr_client()
    registry_id = client.describe_registry()['registryId']
    pullthrough_config = dict()
    for item in paginate(client.describe_pull_through_cache_rules, registryId=registry_id):
        pullthrough_config[item['ecrRepositoryPrefix']] = item['upstreamRegistryUrl']

    return registry_id, pullthrough_config

@dataclass
class ECRRepositoryArn(Arn):
    REST_PATTERN = re.compile(r"repository/(?P<name>.*)")
    name: str = ""

@attr.define(frozen=True, kw_only=True)
class ECRRepository:
    account: Account = attr.field(validator=attr.validators.instance_of(Account))
    registry: str = attr.field(validator=attr.validators.min_len(10))
    arn: ECRRepositoryArn = attr.field(converter=ECRRepositoryArn)

    @property
    def name(self) -> str:
        return self.arn.name

    @property
    def pull_through_source_uri(self) -> str | None:
        _, pullthrough_config = _registry_settings(self.account)
        return pullthrough_config.get(self.name.split('/', 1)[0])

    @property
    def is_properly_named(self) -> bool:
        parts = self.name.split('/')
        if any(len(p) == 0 for p in parts):
            return False
        # Proper naming is ':repository/cloud-city/tenant-name/whatever/whatever...'
        # TODO validate tenant names against known identifiers once those are easily available. They're inconsistent
        #   between IAC, account name, and terraform/terragrunt identifiers at the moment.
        if parts[0] == 'cloud-city' and len(parts) > 2:
            return True
        return False

    @classmethod
    def all_repositories(cls, account: Account):
        registry, pullthrough = _registry_settings(account)
        client = account.ecr_client()
        for repo in paginate(client.describe_repositories, registryId=registry):
            yield cls(
                account=account,
                arn=repo['repositoryArn'],
                registry=registry,
            )
