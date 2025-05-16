from __future__ import annotations

import os
import shlex
from typing import Iterable

from bespin_tools.lib.logging import LoggingMixin
from bespin_tools.lib.util import WINDOWS


class EnvironmentVariables(LoggingMixin, dict):
    _SENSITIVE = "<secret redacted>"
    def __init__(self, log_description: str, initial: dict | None=None):
        if initial is None:
            initial = os.environ
        super().__init__(log_description)
        self._initial = initial.copy()
        self._initial['CLOUD_CITY_BESPINCTL'] = '1'
        with self._logger.temporary_level('ERROR'):
            self.update(self._initial)
        self['GIT_SSL_NO_VERIFY'] = 'true'  # TODO, this is temporary until we give GitLab a real SSL cert.

    def _printable(self, key):
        if key in self and any(x in key for x in ('PASSWORD', 'TOKEN', 'SECRET', 'ACCESS_KEY')):
            return self._SENSITIVE
        return self.get(key)

    def __delitem__(self, key):
        if key in self:
            self._logger.debug(f"")
            self._logger.debug(f"unsetting environment variable '{key}' (was '{self._printable(key)}')")
        else:
            self._logger.debug(f"skipped unsetting command environment variable '{key}'; it was not previously set")
        super().__delitem__(key)

    def __setitem__(self, key, value):
        if shlex.quote(key) != key:
            if WINDOWS:
                if not key.startswith('COMMONPROGRAMFILES'):
                    self._logger.warning(f"Environment variable name is not shell safe: {key}")
            else:
                raise self._exc(f"Variable name is not shell safe: {key}")
        if value is None:
            del self[key]
            return
        assert isinstance(value, str), f"Cannot set {key} to {type(value)} {value}; value must be a string"
        if key != key.upper():
            self._logger.warn(f"environment variable name '{key}' is not all caps")
        if key in self:
            if self.get(key) == value:
                return
            prior = self._printable(key)
            super().__setitem__(key, value)
            self._logger.debug(f"updating environment variable {key}={self._printable(key)} (was '{prior}')")
        else:
            super().__setitem__(key, value)
            self._logger.debug(f"setting previously-unset environment variable {key}={self._printable(key)}")

    def update(self, m: dict):
        for k, v in m.items():
            self[k] = v

    def as_shell_commands(self) -> Iterable[str]:
        for deleted in sorted(set(self._initial.values()).difference(self.keys())):
            yield f"unset ${deleted}"
        for k, v in self.items():
            if self._initial.get(k) != v:
                yield f"export {k}={shlex.quote(v)}"

