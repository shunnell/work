from __future__ import annotations

import asyncio
from collections import defaultdict
from functools import cached_property, lru_cache
from typing import Iterable, Literal, Self

from aiohttp.client_exceptions import ClientError, ClientResponseError

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.dict_resource import AWSDictResource
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.network import probe_url
from bespin_tools.lib.util import stream_results


class EksCluster(AWSDictResource):
    def __init__(self, *args):
        super().__init__(*args)
        self.reachable: Literal[True] | ClientError = ClientError('<reachability not checked>')

    @property
    def id(self) -> str:
        return self['arn']

    @cached_property
    def addons(self):
        return tuple(sorted(paginate(self.account.eks_client().list_addons, clusterName=self.name)))

    @classmethod
    @lru_cache
    def _cluster_names_for_account(cls, account: Account, *include: str):
        include = set(include) if len(include) > 0 else None
        for cluster in paginate(account.eks_client().list_clusters):
            if include is None:
                yield cluster
            elif cluster in include:
                include.discard(cluster)
                yield cluster
        if len(include or ()) > 0:
            raise BespinctlError(f"Requested clusters not found: '{','.join(sorted(include))}'")

    @classmethod
    def _cluster_names_for_accounts(cls, accounts: Iterable[Account], *include: str):
        seen = set()
        for account in accounts:
            for cluster in cls._cluster_names_for_account(account, *include):
                if cluster not in seen:
                    yield account, cluster
                    seen.add(cluster)

    @classmethod
    def _raise_notfound(cls, accounts: Iterable[Account], msg: str):
        available = sorted(s[1] for s in cls._cluster_names_for_accounts(accounts))
        raise BespinctlError(f"{msg}; available choices are: {', '.join(['all'] + available)}")

    @classmethod
    async def _parallel_check_reachability(_, *clusters: Self):
        idx = 0
        async for result in stream_results(probe_url(cluster['endpoint'], timeout=2, ssl=False) for cluster in clusters):
            if isinstance(result, (str, ClientResponseError)):
                reachable = True
            elif 'nodename nor servname provided' in str(result):
                reachable = BespinctlError('DNS resolution failure (VPN disconnected?)')
            else:
                reachable = result
            clusters[idx].reachable = reachable
            idx += 1

    @classmethod
    def _get_clusters(cls, account_to_cluster_name: dict[Account, Iterable[str]]) -> tuple[Self, ...]:
        rv = []
        for account, cluster_names in account_to_cluster_name.items():
            for cluster_name in cluster_names:
                cluster_data = account.eks_client().describe_cluster(name=cluster_name)["cluster"]
                cluster_data['tags']['Name'] = cluster_data['name']
                rv.append(cls(account, cluster_data))
        # In parallel, check reachability for all clusters:
        asyncio.run(cls._parallel_check_reachability(*rv))
        return tuple(sorted(rv))

    @classmethod
    def from_argument(cls, accounts: Iterable[Account], argument: str) -> tuple[Self, ...]:
        requested = set()
        for cluster in argument.split(','):
            requested.add(cluster.split(":cluster/")[-1])
        if len(requested) == 0:
            cls._raise_notfound(accounts, "An EKS cluster must be supplied")
            raise  # Unreachable: to satisfy the linter,
        else:
            account_to_cluster_names = defaultdict(list)
            for account, cluster_name in cls._cluster_names_for_accounts(
                accounts,
        *(() if 'all' in requested else requested)
            ):
                requested.discard('all')
                requested.discard(cluster_name)
                account_to_cluster_names[account].append(cluster_name)
            if len(requested) > 0:
                cls._raise_notfound(accounts, f"EKS clusters {','.join(sorted(requested))} not found")
            return cls._get_clusters(account_to_cluster_names)

    @classmethod
    def _query(cls, account, **filters):
        return cls._get_clusters({account: paginate(account.eks_client().list_clusters, **filters)})
