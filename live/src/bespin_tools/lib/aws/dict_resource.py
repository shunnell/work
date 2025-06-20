from __future__ import annotations

from abc import ABC, abstractmethod
from copy import deepcopy
from functools import lru_cache
from typing import Mapping, Iterable, Self, Sequence

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import convert_tags_for_display


class AWSDictResource(ABC, Mapping):
    def __init__(self, account: Account, raw: Mapping):
        self._raw = {**deepcopy(raw), 'Tags': convert_tags_for_display(raw.get('Tags', ()))}
        self.tags: Mapping = self._raw['Tags']
        self.account = account
        self.name = self.tags['Name']

    @property
    @abstractmethod
    def id(self) -> str:
        raise NotImplementedError

    @classmethod
    @abstractmethod
    def _query(cls, account: Account, **filters) -> Iterable[Self]:
        raise NotImplementedError

    @classmethod
    @lru_cache
    def query(cls, *account_filters, **resource_filters) -> Sequence[Self]:
        if len(account_filters) == 0:
            account_filters = (Organization.ALL,)
        rv = []
        for account in sorted(Organization.get_accounts(*account_filters)):
            rv.extend(sorted(cls._query(account, **resource_filters)))
        return tuple(rv)

    def __hash__(self):
        return hash(self.id)

    def __eq__(self, other):
        if not isinstance(other, type(self)):
            raise ValueError(f"Cannot compare {type(self)} to {type(other)}")
        return self.id == other.id

    def __lt__(self, other):
        if not isinstance(other, type(self)):
            raise ValueError(f"Cannot compare {type(self)} to {type(other)}")
        return self.id < other.id

    def __getitem__(self, item):
        return self._raw[item]

    def __len__(self):
        return len(self._raw)

    def __iter__(self):
        return self._raw.__iter__()

    def __str__(self):
        return f"{self.id} ({self.name})"