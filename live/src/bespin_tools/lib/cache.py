from __future__ import annotations

import hashlib
import inspect
import json
import os
import shutil
from contextlib import contextmanager, nullcontext
from datetime import timedelta, datetime
from functools import cache, wraps, partial
from os.path import expanduser, expandvars
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import ContextManager, TextIO, Iterable, IO, Generator
from retrying import retry
from xdg import BaseDirectory
import attr
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.logging import info, debug
from bespin_tools.lib.python_files import python_cache_paths
from bespin_tools.lib.util import WINDOWS, resolve_directory, resolve_file


@cache
def cache_root() -> Path:
    rv = Path(BaseDirectory.save_cache_path('bespinctl')).resolve()
    rv.mkdir(exist_ok=True)
    if user := os.environ.get("SUDO_USER"):
        # Make sure the cache dir isn't owned by root
        shutil.chown(rv, user=user)
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
        self.relative_path = path.relative_to(cache_root())
        self.exists = self.path.exists
        debug(f"Initializing cache management (directory? {directory}; exists? {self.exists()}): {self.path}")

    @staticmethod
    def _part(path: str) -> Path:
        BespinctlError.invariant(not path.startswith('.'), f'Cache path cannot start with a dot: {path}')
        BespinctlError.invariant('..' not in path, f'Cache path cannot contain "..": {path}')
        path = Path(path)
        BespinctlError.invariant(len(path.parts) == 1, f"Cache path has directory parts: {path}")
        return path

    @staticmethod
    @retry(wait_fixed=1000, stop_max_attempt_number=10, retry_on_exception=(BespinctlError,))
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
                f"Could not lock file {lockfh.name} (retry for up to 10sec); another instance of bespinctl may be running. Check 'ps'/Activity Monitor/Task Manager for other bespinctl processes, clear-caches, then try again.")
            err.show()
            raise err from ex

    @contextmanager
    def lock(self):
        path = self.relative_path
        lock_path = CachePath('locks', '_'.join(path.parts))
        with lock_path.open('w', lock=False) as lockfh:
            self._platform_specific_lock(lockfh)
            yield lockfh

    @contextmanager
    def open(self, mode: str = 'a+', lock=True) -> Generator[IO | Path]:
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


def _ttl_expired(path: Path | IO, ttl: timedelta | None) -> bool:
    if ttl is None:
        return False
    stat = path.stat() if isinstance(path, Path) else os.stat(path.fileno())
    mtime = datetime.fromtimestamp(stat.st_mtime)
    return (datetime.now() - mtime) >= ttl


def _todict(item):
    try:
        return attr.asdict(item, recurse=True, filter=lambda a, _: a.hash)
    except attr.exceptions.NotAnAttrsClassError:
        return item

def _cache_args_key(*args, **kwargs):
    dumper = partial(json.dumps, sort_keys=True, indent=0)
    yield dumper([_todict(i) for i in args])
    for k, v in sorted(kwargs.items()):
        yield dumper(_todict(k))
        yield dumper(_todict(v))


def _cache_result(func: callable, *, hasher: callable, ttl: timedelta=None, name=None, __used=set()):
    BespinctlError.invariant(inspect.isgeneratorfunction(hasher), f"Must be a generator function: {hasher}")
    if name is None:
        name = func.__qualname__
    BespinctlError.invariant(name not in __used, f"Function is already cached: {name}")
    __used.add(name)
    cache_base = CachePath('functions', name, directory=True)

    @wraps(func)
    def inner(*args, **kwargs):
        digester = hashlib.sha256()
        for item in hasher(*args, **kwargs):
            if isinstance(item, str):
                item = item.encode()
            digester.update(item)
        with CachePath(*cache_base.relative_path.parts, digester.hexdigest()).open() as cachefh:
            # If it's empty, or if its mtime (expiration) has passed, update it
            data = cachefh.read(1)
            cachefh.seek(0)
            if len(data) == 0 or _ttl_expired(cachefh, ttl):
                cachefh.truncate(0)
                debug(f"Priming cache for '{name}': cache is {'empty' if data == '' else 'expired'}")
                result = func(*args, **kwargs)
                debug(f"Writing JSON cache result for '{name}': {result}")
                json.dump(result, cachefh)
                debug(f"Wrote cache for '{name}'")
                return result
            rv = cachefh.read()
            debug(f"Returning data from cache: {rv}")
            return json.loads(rv)

    return inner

def cache_result(ttl: timedelta=None, name=None, hasher=_cache_args_key):
    return partial(_cache_result, ttl=ttl, name=name, hasher=hasher)

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

@contextmanager
def isolated_kubernetes_files() -> Generator[tuple[Path, Path]]:
    base = CachePath('kube', directory=True)
    with TemporaryDirectory(dir=base.path) as directory:
        directory = Path(directory)
        directory.joinpath('cache').mkdir()
        file = directory.joinpath('kubeconfig.yaml')
        file.write_text('')
        yield file, directory.joinpath('cache')

def _unique_resolved_paths(*args: Path | str):
    resolved = {Path(p).expanduser().resolve() for p in args}
    yield from sorted(resolved)

def external_cache_paths() -> Iterable[Path]:
    if WINDOWS:
        home = Path(expandvars('%UserProfile%'))
        cache_roots = ()
    else:
        home = Path(expanduser('~'))
        cache_roots = (home.joinpath('Library', 'Caches'),)

    for cache_root in _unique_resolved_paths(
        home.joinpath('.cache'),
        BaseDirectory.xdg_cache_home,
        *cache_roots,
    ):
        for subpath in ('terragrunt', 'terraform', 'terraform.d', 'aws', 'awscli'):
            yield cache_root.joinpath(subpath)
            yield cache_root.joinpath(f".{subpath}")
    # UV installs tools, like this one, into the data path at ~/.local/share.
    # https://docs.astral.sh/uv/concepts/tools/#tool-executables
    for data_root in _unique_resolved_paths(home.joinpath('.local', 'share'), BaseDirectory.xdg_data_home):
        yield from python_cache_paths(data_root.joinpath('uv'))
    # https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-role.html#cli-configure-role-cache
    yield Path(home, '.aws/cli/cache')
    yield Path(home, '.aws/credentials/cache')
    yield Path(home, '.aws/cache')
