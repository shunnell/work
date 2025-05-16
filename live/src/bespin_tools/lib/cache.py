from __future__ import annotations

import json
from contextlib import contextmanager, nullcontext
from functools import cache
from os.path import expanduser, expandvars
from pathlib import Path
from typing import ContextManager, TextIO, Iterable, IO

from retrying import retry
from xdg import BaseDirectory

from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.logging import info
from bespin_tools.lib.util import WINDOWS, resolve_directory, resolve_file


@cache
def cache_root() -> Path:
    rv = Path(BaseDirectory.save_cache_path('bespinctl')).resolve()
    rv.mkdir(exist_ok=True)
    return rv


class CachePath:
    def __init__(self, *parts: str, directory=False):
        path = cache_root()
        for part in parts:
            path = path.joinpath(self._part(part))
        if path.exists():
            path = resolve_directory(path) if directory else resolve_file(path)
        elif directory:
            path.mkdir(parents=True, exist_ok=True)
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
        self.directory = directory
        self.path = path
        self.exists = self.path.exists

    @staticmethod
    def _part(path: str) -> Path:
        assert not path.startswith('.'), f'Cache path cannot start with a dot: {path}'
        assert not '..' in path, f'Cache path cannot contain "..": {path}'
        path = Path(path)
        assert len(path.parts) == 1, f"Cache path has directory parts: {path}"
        return path

    @staticmethod
    @retry(wait_fixed=1000, stop_max_attempt_number=5, retry_on_exception=(BespinctlError,))
    def _platform_specific_lock(lockfh):
        # https://stackoverflow.com/questions/30440559
        try:
            if WINDOWS:
                import msvcrt
                msvcrt.locking(lockfh.fileno(), msvcrt.LK_RLCK, 1)
            else:
                import fcntl
                fcntl.flock(lockfh, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except (OSError if WINDOWS else BlockingIOError) as ex:
            err = BespinctlError(
                f"Could not lock file {lockfh.name} (retry for up to 5sec); another instance of bespinctl may be running. Check 'ps'/Activity Monitor/Task Manager for other bespinctl processes, clear-caches, then try again.")
            err.show()
            raise err from ex


    @contextmanager
    def lock(self):
        path = self.path.relative_to(cache_root())
        lock_path = CachePath('locks', '_'.join(path.parts))
        with lock_path.open('w', lock=False) as lockfh:
            self._platform_specific_lock(lockfh)
            yield lockfh

    @contextmanager
    def open(self, mode: str = 'a+', lock=True):
        # Because file locking on windows fights with various pieces of code's interactions with the path, we use an
        # external lockfile rather than locking the cache resource directly. Since all cache accesses go through this
        # function, that shouldn't induce race conditions.
        lock_mgr = self.lock() if lock else nullcontext()
        with lock_mgr as _:
            if self.directory:
                yield self.path
            else:
                with open(self.path, mode) as cachefh:
                    cachefh.seek(0)
                    yield cachefh


@contextmanager
def cached_binary(binary_name: str):
    binary_name = binary_name.removesuffix('.exe')
    suffix = ".exe" if WINDOWS else ""
    binary = CachePath("bin", f"{binary_name}{suffix}")
    with binary.lock():
        yield binary.path


def update_cache_filehandle(fh: IO, get_data: callable, reason: str, is_json=True):
    # Wipe cache before calling (fallible) cache prime functions to prevent endless failures due to poisoned caches.
    fh.seek(0)
    fh.truncate()
    info(f"Updating cache at {fh.name}: {reason}")
    data = get_data()
    if is_json:
        json.dump(data, fh, sort_keys=True, indent=8)
    else:
        for line in (data,) if isinstance(data, (str, bytes)) else data:
            fh.write(line.rstrip('\n'))
            fh.write('\n')
    fh.flush()
    info(f"Updated cache at {fh.name}")
    fh.seek(0)  # Just in case it's used subsequently
    return data

def organization_schema_cache() -> ContextManager[TextIO]:
    return CachePath('accounts_roles_regions').open()

def sso_credentials_cache() -> ContextManager[TextIO]:
    return CachePath('aws_sso_credentials').open()

def terraform_provider_cache() -> Path:
    # Silly short names because path length is a resource in short supply on Windows:
    with CachePath('tf', 'prov',  directory=True).open(lock=False) as rv:
        info(f"Using terraform/terragrunt provider cache at {rv}")
        return rv

def terragrunt_terraform_module_cache() -> Path:
    # Silly short names because path length is a resource in short supply on Windows.
    with CachePath(
        'tg',
        'mod', # Per-module-dir hash-named directories will be created in here.
        directory=True,
    ).open(lock=False) as rv:
        info(f"Using terraform module cache at {rv}")
        return rv

def dummy_aws_config_file() -> Path:
    with CachePath('dummy_aws_config').open() as fh:
        fh.truncate(0)
        fh.write('[bespinctl]\n')
        return Path(fh.name)

def external_cache_paths() -> Iterable[Path]:
    if WINDOWS:
        home = Path(expandvars('%UserProfile%'))
        cache_roots = ()
    else:
        home = Path(expanduser('~'))
        cache_roots = (home.joinpath('Library', 'Caches'),)

    for cache_root in {home.joinpath('.cache'), BaseDirectory.xdg_cache_home, *cache_roots}:
        for subpath in ('terragrunt', 'terraform', 'terraform.d', 'aws', 'awscli'):
            yield Path(cache_root, subpath).expanduser()
            yield Path(cache_root, f".{subpath}")
    # https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-role.html#cli-configure-role-cache
    yield Path(home, '.aws/cli/cache')
    yield Path(home, '.aws/credentials/cache')
    yield Path(home, '.aws/cache')
