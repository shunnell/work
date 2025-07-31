from __future__ import annotations

import threading
from abc import ABC, abstractmethod
from concurrent.futures import Future
from datetime import UTC
from datetime import datetime, timedelta
from typing import Dict
from typing import TYPE_CHECKING

import attr

from bespin_tools.lib.logging import LoggingMixin
from bespin_tools.lib.util import background_initialized

if TYPE_CHECKING:
    from types_boto3_sso import SSOClient
    from types_boto3_sts import STSClient

class _Expired(RuntimeError): ...

@attr.define(kw_only=True)
class _BaseRoleCredentials(LoggingMixin, ABC):
    _client: STSClient | SSOClient = attr.field()
    account: str = attr.field(validator=attr.validators.min_len(12))
    role: str = attr.field()
    _expire_before_ttl: timedelta = attr.field(default=timedelta(seconds=30))

    _cache: Dict[tuple, Future[dict | Exception]] = {}
    _cache_miss: Future[Exception] = Future()
    _cache_miss.set_result(_Expired())

    def __attrs_post_init__(self):
        super().__init__(f'{type(self).__name__}:{self.role}@{self.account}')
        # Start background creds fetch on init:
        self._cache[self._cache_key()] = background_initialized(self._wrap_get_credentials, proxy=False)()

    def _cache_key(self) -> tuple:
        return self.account, self.role

    def _wrap_get_credentials(self) -> dict | Exception:
        try:
            result = self._get_credentials()
        except Exception as ex:
            return ex
        result.pop('ResponseMetadata', None)
        if result['Expiration'] < (datetime.now(UTC) - self._expire_before_ttl):
            raise _Expired
        return result

    def client_kwargs(self) -> dict:
        assert threading.current_thread() == threading.main_thread(), f"Called from thread {threading.current_thread()}"
        cached = self._cache.get(self._cache_key(), self._cache_miss)
        result = cached.result()
        computed = False
        # TODO this is wrong; raise vs return is ugly, needs significant cleanup
        if isinstance(result, _Expired):
            self._logger.warning("Cached credentials expired")
            cached = self._cache[self._cache_key()] = background_initialized(self._wrap_get_credentials, proxy=False)()
            result = cached.result()
            computed = True
        if isinstance(result, Exception):
            self._logger.error(f"Failed to get credentials: {result}", exc_info=result)
            del self._cache[self._cache_key()]
            raise result
        result = result.copy()
        rv = dict(
            aws_access_key_id=result.pop('AccessKeyId'),
            aws_secret_access_key=result.pop('SecretAccessKey'),
            aws_session_token=result.pop('SessionToken'),
        )
        exp = result.pop('Expiration')
        if computed:
            self._logger.info(f"Assumed role {self.role}, expires at {exp}")
        else:
            self._logger.debug(f"Retrieved cached credentials for role {self.role}, expires at {exp}")
        for k in sorted(result.keys()):
            self._logger.debug(f"Additional role assume metadata: {k}={result[k]}")
        return rv

    def environment_kwargs(self):
        return {k.upper(): v for k, v in self.client_kwargs().items()}

    @abstractmethod
    def _get_credentials(self) -> dict:
        raise NotImplementedError

@attr.define(kw_only=True)
class SSORoleCredentials(_BaseRoleCredentials):
    _token: str = attr.field()
    def _cache_key(self) -> tuple:
        return *super()._cache_key(), self._token

    def _get_credentials(self):
        role_creds = self._client.get_role_credentials(
            roleName=self.role,
            accountId=str(self.account),
            accessToken=self._token,
        )['roleCredentials']
        # Unlike STS creds, this one's expiration is an epoch timestamp in milliseconds. Yay consistency!
        role_creds['expiration'] = datetime.fromtimestamp(role_creds['expiration'] / 1000, UTC)
        return {f"{k[0].upper()}{k[1:]}": v for k, v in role_creds.items()}

@attr.define(kw_only=True)
class STSRoleCredentials(_BaseRoleCredentials):
    _session_name: str = attr.field()
    _external_id: str | None = attr.field()

    def _get_credentials(self):
        role_data = dict(self._client.assume_role(
            RoleArn=self.role,
            RoleSessionName=self._session_name,
            ExternalId=self._external_id,
        ))
        role_creds = role_data.pop('Credentials')
        return {**role_data, **role_creds}
