from __future__ import annotations

import logging
import subprocess
from abc import ABC, abstractmethod
from pathlib import Path
from time import monotonic

import attr
from packaging.specifiers import SpecifierSet
from packaging.version import Version

from bespin_tools.lib.cache import cache_root
from bespin_tools.lib.command.environment import EnvironmentVariables
from bespin_tools.lib.logging import LoggingMixin
from bespin_tools.lib.util import resolve_executable, resolve_directory


@attr.define(str=False)
class BaseCommand(ABC, LoggingMixin):
    name: str = attr.field(on_setattr=attr.setters.frozen)
    version_constraints: SpecifierSet | str = attr.field(
        kw_only=True,
        on_setattr=attr.setters.frozen,
        default=SpecifierSet(),
        converter=SpecifierSet,
    )
    env: EnvironmentVariables = attr.field(
        init=False,
        repr=False,
        default=attr.Factory(lambda self: EnvironmentVariables(self.name), takes_self=True),
    )
    path: Path | None = attr.field(init=False, default=None)

    def __attrs_post_init__(self):
        super().__init__('_')
        self._logger.change_prefix(self._logger_prefix(False))
        self.path = self._resolve()
        self._logger.change_prefix(self._logger_prefix(True), append=False)

    def _logger_prefix(self, installed: bool, *args):
        parts = []
        if self._logger.getEffectiveLevel() <= logging.DEBUG:
            parts.extend((type(self).__name__, self.path if installed else f"<installing '{self.name}'>"))
        else:
            parts.append(self.name if installed else f"installing '{self.name}'")
        parts.extend(args)
        return " ".join(parts)

    def _get_version(self, cmd: Path) -> str:
        # If we're in a directory stack or nonexistent directory, version checking can crash, which is weird, so always
        # set cwd to a place that we know exists.
        version_info = subprocess.check_output((cmd, '--version'), cwd=cache_root()).decode().split('\n')[0].strip()
        return version_info.rsplit()[-1]

    def _validate_local_executable(self, value: str | Path | None) -> Path:
        exc_cls = type(self._exc(''))
        try:
            if value is None:
                raise self._exc(f"Could not find command '{self.name}'")
            cmd = resolve_executable(value)

            if len(self.version_constraints) > 0:
                detected = Version(self._get_version(cmd))
                if detected not in self.version_constraints:
                    raise self._exc(f"Tool '{self.name}' ({cmd}) reported an invalid version; expected {self.version_constraints}, got {detected}",)
            return cmd
        except (KeyboardInterrupt, exc_cls):
            raise
        except Exception as ex:
            raise self._exc(f'Could not validate executable for {value}', exc_info=ex) from ex

    @abstractmethod
    def _resolve(self) -> Path:
        raise NotImplemented

    # TODO return output optionally printing as well
    def run(self, *args):
        args = tuple(str(a) if isinstance(a, Path) else a for a in args)
        resolve_directory(Path())  # Assert that cwd exists; if it doesn't, inscrutable errors can occur.
        self._logger.change_prefix(self._logger_prefix(True, *args), append=False)
        self._logger.info("Starting subprocess")
        t0 = monotonic()
        try:
            subprocess.check_call((self.path, *args), env=self.env, shell=False)
            t0 = round(monotonic() - t0, 2)
            self._logger.success(f"Subprocess succeeded after {t0}sec")
        except subprocess.CalledProcessError as ex:
            t0 = round(monotonic() - t0, 2)
            raise self._exc(
                f"Subprocess failed after {t0}sec with exit status {ex.returncode}; check above error output for failure",
                exit_code=ex.returncode,
            ) from ex
        finally:
            self._logger.change_prefix(self._logger_prefix(True), append=False)
