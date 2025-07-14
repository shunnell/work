from __future__ import annotations

import json
import re
from collections import defaultdict
from dataclasses import dataclass
from functools import cache, cached_property
from typing import Mapping, TYPE_CHECKING

import attr
from arn import Arn

from bespin_tools.lib.aws import suppress_boto_error
from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.ecr.vulnerabilities import ECRVulnerabilities
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.git_repo import git_repo_root
from bespin_tools.lib.logging import warn

if TYPE_CHECKING:
    from types_boto3_ecr import ECRClient


@cache
def _grandfathered_in_repos() -> Mapping[str, frozenset[str]]:
    """
    Returns a mapping in which the keys are tenant folder names and the values are sets of repos which are owned by
    that tenant but are not managed in Cloud City's standard ECR naming scheme.
    """
    import hcl2  # Runtime import to save a little startup time

    root = git_repo_root()[1]
    rv = defaultdict(set)
    for repo_hcl in root.glob("infra/*/ecr/repositories/terragrunt.hcl"):
        assert repo_hcl.is_file()
        tenant_name = repo_hcl.relative_to(root).parts[1]
        repos_for_tenant = rv[tenant_name]
        parsed_hcl: dict = hcl2.loads(repo_hcl.read_text())
        repos_for_tenant.update(
            parsed_hcl.get("inputs", {}).get(
                "legacy_ecr_repository_names_to_be_migrated", ()
            )
        )
    return {k: frozenset(v) for k, v in rv.items()}


@cache
def _registry_settings(account: Account):
    client = account.ecr_client()
    registry_id = client.describe_registry()["registryId"]
    pullthrough_config = dict()
    for item in paginate(
        client.describe_pull_through_cache_rules, registryId=registry_id
    ):
        pullthrough_config[item["ecrRepositoryPrefix"]] = item["upstreamRegistryUrl"]

    return registry_id, pullthrough_config


def _maybe_json(item):
    if isinstance(item, (bytes, str)):
        return json.loads(item)
    return item


@dataclass
class ECRRepositoryArn(Arn):
    REST_PATTERN = re.compile(r"repository/(?P<name>.*)")
    name: str = ""

    def __hash__(self):
        return hash(str(self))


@attr.define(frozen=True, kw_only=True)
class ECRRepositoryBase:
    account: Account = attr.field(validator=attr.validators.instance_of(Account))
    client: ECRClient = attr.field(hash=False)
    tag_mutability: Mapping = attr.field(hash=False)  # Just a string, not JSON
    encryption_configuration: Mapping = attr.field(hash=False, converter=_maybe_json)


@attr.define(frozen=True, kw_only=True)
class ECRRepositoryTemplate(ECRRepositoryBase):
    lifecycle_policy: str = attr.field(hash=False, converter=_maybe_json)
    permissions_policy: str = attr.field(hash=False, converter=_maybe_json)

    @classmethod
    @cache
    def all_templates(cls, account: Account):
        client = account.ecr_client()
        prefixes = defaultdict(dict)
        for item in paginate(client.describe_repository_creation_templates):
            if item["prefix"] == "ROOT":
                continue
            for key in (
                "encryptionConfiguration",
                "imageTagMutability",
                "lifecyclePolicy",
                "repositoryPolicy",
            ):
                prefixes[item["prefix"]][key] = item[key]
        prefix_keys = frozenset(prefixes.keys())
        rv = dict()
        for prefix, config in prefixes.items():
            for other_prefix in prefix_keys.difference({prefix}):
                BespinctlError.invariant(
                    not other_prefix.startswith(prefix),
                    f"Prefix conflict: '{prefix}' vs '{other_prefix}",
                )
            rv[prefix] = ECRRepositoryTemplate(
                account=account,
                client=client,
                encryption_configuration=config["encryptionConfiguration"],
                tag_mutability=config["imageTagMutability"],
                lifecycle_policy=config["lifecyclePolicy"],
                permissions_policy=config["repositoryPolicy"],
            )
        return rv


@attr.define(frozen=True, kw_only=True)
class ECRRepository(ECRRepositoryBase):
    arn: ECRRepositoryArn = attr.field(converter=ECRRepositoryArn)
    registry: str = attr.field(validator=attr.validators.min_len(10))
    vulnerabilities: ECRVulnerabilities = attr.field(factory=ECRVulnerabilities, init=False, hash=False)

    @cached_property
    @suppress_boto_error("LifecyclePolicyNotFoundException")
    def lifecycle_policy(self) -> Mapping | None:
        return _maybe_json(
            self.client.get_lifecycle_policy(
                repositoryName=self.name,
                registryId=self.registry,
            )["lifecyclePolicyText"]
        )

    @cached_property
    @suppress_boto_error("RepositoryPolicyNotFoundException")
    def permissions_policy(self) -> Mapping | None:
        return _maybe_json(
            self.client.get_repository_policy(
                repositoryName=self.name,
                registryId=self.registry,
            )["policyText"]
        )

    @cached_property
    def images(self) -> tuple[str, ...]:
        # Intentionally not sorted so that latest is first:
        return tuple(paginate(self.client.list_images, repositoryName=self.name))

    @property
    def grandfathered(self) -> bool:
        return any(self.name in v for v in _grandfathered_in_repos().values())

    @property
    def owner(self) -> str:
        grandfathered = _grandfathered_in_repos()
        if owners := [k for k, v in grandfathered.items() if self.name in v]:
            BespinctlError.invariant(
                len(owners) == 1,
                f"Grandfathered repo '{self.name}' has indeterminate owner; could be any of {owners}",
            )
        elif owners := [
            o for o in grandfathered.keys() if self.name.startswith(f"{o}/")
        ]:
            BespinctlError.invariant(
                len(owners) == 1,
                f"Correctly-named repo '{self.name}' has indeterminate owner; could be any of {owners}",
            )
        else:
            warn(
                f"ECR repository '{self.name}' does not have an owner; defaulting to platform"
            )
            owners = ["platform (unknown)"]
        return owners[0]

    @property
    def name(self) -> str:
        return self.arn.name

    @property
    def pull_through_source_uri(self) -> str | None:
        _, pullthrough_config = _registry_settings(self.account)
        rv = None
        for prefix, upstream in pullthrough_config.items():
            if self.name.startswith(prefix):
                BespinctlError.invariant(rv is None, f"Repo {self} already has a pull through prefix: {rv}")
                rv = prefix
        return rv

    @property
    def creation_template(self) -> ECRRepositoryTemplate:
        template = None
        for prefix, settings in ECRRepositoryTemplate.all_templates(
            self.account
        ).items():
            if self.name.startswith(prefix):
                BespinctlError.invariant(
                    template is None,
                    f"Image '{self.name}' already has a creation template: {template}",
                )
                template = settings
        return template

    @property
    def is_properly_named(self) -> bool:
        parts = self.name.split("/")
        if any(len(p) == 0 for p in parts):
            return False
        # Proper naming is ':repository/cloud-city/tenant-name/whatever/whatever...'
        # TODO validate tenant names against known identifiers once those are easily available. They're inconsistent
        #   between IAC, account name, and terraform/terragrunt identifiers at the moment.
        if parts[0] == "cloud-city" and len(parts) > 2:
            return True
        return False

    @classmethod
    def all_repositories(cls, account: Account):
        registry, pullthrough = _registry_settings(account)
        client = account.ecr_client()
        for repo in paginate(client.describe_repositories, registryId=registry):
            yield cls(
                account=account,
                arn=repo["repositoryArn"],
                registry=registry,
                client=client,
                encryption_configuration=repo["encryptionConfiguration"],
                tag_mutability=repo["imageTagMutability"],
            )
