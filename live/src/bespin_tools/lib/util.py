from __future__ import annotations

import os
import platform
from asyncio import ensure_future, as_completed, gather
from concurrent.futures import Future
from functools import wraps
from pathlib import Path
from tempfile import TemporaryFile
from threading import Thread
from typing import Callable, Iterable, Awaitable

import lazy_object_proxy

from bespin_tools.lib.errors import BespinctlError

WINDOWS = platform.system().lower().startswith('win')


def iterdir(path: Path, topdown=True) -> Iterable[Path]:
    path = resolve_directory(path)
    for root, dirs, files in os.walk(path, topdown=topdown, followlinks=True):
        if '.git' in dirs:
            dirs.remove('.git')
        # Ensure __init__.py files are first, for use in recursive imports (False < True):
        for name in sorted(files, key=lambda x: (x != "__init__.py", x)):
            yield Path(root).joinpath(name)
        for name in dirs:
            yield Path(root).joinpath(name)

def _check_path(path: Path | str, isdir: bool):
    path = Path(path).resolve()
    if not path.exists():
        raise BespinctlError(f"Expected path '{path}' not found")
    if isdir:
        if not path.is_dir():
            raise BespinctlError(f"Expected path '{path}' exists but is not a directory")
    elif not path.is_file():
        raise BespinctlError(f"Expected path '{path}' exists but is not a file")
    return path

def resolve_nonexistent(path: Path | str) -> Path:
    path = Path(path).resolve()
    if path.exists():
        raise BespinctlError(f"Path '{path}' already exists")
    resolve_directory(path.parent)
    return path

def resolve_file(path: Path | str) -> Path:
    path = _check_path(path, False)
    try:
        path.read_bytes()
    except OSError as ex:
        raise BespinctlError(f"Expected file '{path}' exists but cannot be read: {ex}", exc_info=ex)
    return path

def resolve_directory(path: Path | str) -> Path:
    path = _check_path(path, True)
    try:
        tuple(path.iterdir())
        with TemporaryFile(dir = path):
            ...
    except OSError as ex:
        raise BespinctlError(f"Expected directory '{path}' exists cannot be used (possible permissions issue): {ex}", exc_info=ex)
    return path

def resolve_executable(path: Path | str) -> Path:
    path = resolve_file(path)
    if not os.access(path, os.X_OK):
        raise BespinctlError(f"Expected file '{path}' exists but is not executable")
    return path


def _attempt(future: Future, func, args, kwargs):
    try:
        future.set_result(func(*args, **kwargs))
    except Exception as ex:
        future.set_exception(ex)
        raise


def is_empty_dir(path: Path) -> bool:
    for _ in path.iterdir() if path.is_dir() else (None,):
        return False
    return True

async def stream_results(awaitables: Iterable[Awaitable], timeout: int | None = None):
    awaitables = {ensure_future(i) for i in awaitables}
    try:
        async for item in as_completed(awaitables, timeout=timeout):
            yield await item
    finally:
        for item in awaitables:
            if not item.done():
                item.cancel()
        await gather(*awaitables, return_exceptions=True)

def background_initialized[T, **P](func: Callable[P, T], proxy=True) -> Callable[P, T | Future[T]]:
    @wraps(func)
    def wrapped(*args: P.args, **kwargs: P.kwargs) -> T:
        # Not using a ThreadPoolExecutor since those block at process exit, waiting for work to complete. We want to
        # discard backgrounded incomplete work when Python exits: it's "background *initialized*", not "background
        # do sensitive transactional things".
        # Ref of TPE not using daemon threads: https://bugs.python.org/issue39812
        future = Future()
        Thread(
            target=_attempt,
            args=(future, func, args, kwargs),
            daemon=True,
            name=f"bespinctl: {func.__qualname__}",
        ).start()
        return lazy_object_proxy.Proxy(future.result) if proxy else future

    return wrapped