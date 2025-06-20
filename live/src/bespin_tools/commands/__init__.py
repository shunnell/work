from __future__ import annotations

import shutil
from pathlib import Path

import click

from bespin_tools.lib.cache import external_cache_paths, cache_root
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.git_repo import empty_dirs
from bespin_tools.lib.iac import iac_files, iac_repos
from bespin_tools.lib.logging import info, verbosity_option, debug_option
from bespin_tools.lib.python_files import python_cache_paths
from bespin_tools.lib.util import is_empty_dir


@click.group()
@click.version_option()
@debug_option("--debug", "-v")
@verbosity_option("--log-level", "-l")
def bespinctl() -> None:
    ...

def _caches_to_remove():
    if not is_empty_dir(cache_root()):
        yield cache_root()
    yield from external_cache_paths()
    yield from python_cache_paths(Path(__file__).parent)

    for _, repo in iac_repos():
        yield from iac_files(repo, ignored=True)
        yield from python_cache_paths(repo)
        yield from empty_dirs(repo)


@bespinctl.command()
@click.option('--execute', is_flag=True, default=False, help="If set, actually delete files")
def clear_caches(execute: bool):
    if execute:
        prefix = "Removing"
    else:
        prefix = "(Noop: pass --execute to remove files) would have removed"
    try:
        for toremove in _caches_to_remove():
            if toremove.is_dir():
                if is_empty_dir(toremove):
                    info(f"{prefix} empty directory {toremove}")
                    if execute:
                        toremove.rmdir()
                else:
                    info(f"{prefix} directory {toremove}")
                    if execute:
                        shutil.rmtree(toremove)
            elif toremove.exists():
                info(f"{prefix} file {toremove}")
                if execute:
                    toremove.unlink(missing_ok=True)
    except PermissionError as ex:
        raise BespinctlError(f"Failed to remove caches in '{toremove}'; try running clear-caches with elevated permissions, or remove that path manually.") from ex

    # TODO remove k8s cache dirs
