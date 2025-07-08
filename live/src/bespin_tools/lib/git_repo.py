from __future__ import annotations

import itertools
import os
from functools import cache
from pathlib import Path
from typing import Tuple, Iterable
from urllib.parse import urlparse, ParseResult

import git

from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.util import is_empty_dir, iterdir

CLOUD_CITY_GITLAB_URI = 'gitlab.cloud-city'


def _parsed_remotes(repo: git.Repo) -> Iterable[ParseResult]:
    for remote in repo.remotes:
        for url in remote.urls:
            parsed = urlparse(url)
            if len(parsed.password or ""):
                parsed = urlparse(url.replace(parsed.password, '<password redacted>'))
            yield parsed

def cloud_city_repos() -> Iterable[tuple[git.Repo, Path, ParseResult]]:
    repo, root = git_repo_root()
    for adjacent in root.parent.iterdir():
        if parts := git_repo_or_none(adjacent):
            repo, root = parts
            remotes = set(_parsed_remotes(repo))
            if any(CLOUD_CITY_GITLAB_URI in r.path or CLOUD_CITY_GITLAB_URI in r.hostname for r in remotes):
                if len(remotes) > 1:
                    raise BespinctlError(f"Cloud City git repo at {root} has multiple remotes, which is unsupported in bespinctl: {sorted(remotes)}")
                yield repo, root, remotes.pop()

def empty_dirs(path: Path) -> Iterable[Path]:
    yield from filter(is_empty_dir, iterdir(path, topdown=False))


def git_repo_or_none(path: Path | str) -> tuple[git.Repo, Path] | None:
    from bespin_tools.lib.logging import logger # Local import to avoid import loops

    path = Path(path).resolve()

    if path.is_dir():
        try:
            return git_repo_root(path)
        except git.NoSuchPathError as ex:
            logger.warning(f"Cannot clean up files in '{path}': could not read path to check if it is a git repository: {ex}")
        except git.GitCommandError as ex:
            if 'must be run in a work tree' in str(ex).lower():
                logger.warning(f"Cannot clean up files in '{path}': no git repo found: {ex}")
            else:
                raise
        except git.InvalidGitRepositoryError:
            logger.debug(f"Directory is not a git repo: {path}")
            pass
    return None

@cache
def git_repo_root(path: Path | str | None = None) -> tuple[git.Repo, Path]:
    from bespin_tools.lib.logging import logger # Local import to avoid import loops

    if path is None:
        path = __file__
    path = Path(path)
    logger.debug(f"{path}: checking for git repo...")
    git_repo = git.Repo(path, search_parent_directories=True)
    return git_repo, Path(git_repo.git.rev_parse("--show-toplevel")).resolve()
