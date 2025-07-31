from __future__ import annotations

from functools import cache
from pathlib import Path
from typing import TYPE_CHECKING, Iterable
from urllib.parse import urlparse, ParseResult

from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.util import resolve_readable

if TYPE_CHECKING:
    from git import Repo

CLOUD_CITY_GITLAB_URI = 'gitlab.cloud-city'

class InvalidGitRepository(BespinctlError):
    def __init__(self, path: Path | str, msg=""):
        if len(msg) > 0:
            msg = f": {msg}"
        super().__init__(f"{path}: Path is not readable or not in a valid git repository{msg}")


def _parsed_remotes(repo: Repo) -> Iterable[ParseResult]:
    for remote in repo.remotes:
        for url in remote.urls:
            parsed = urlparse(url)
            if len(parsed.password or ""):
                parsed = urlparse(url.replace(parsed.password, '<password redacted>'))
            yield parsed

def cloud_city_repos() -> Iterable[tuple[Repo, Path, ParseResult]]:
    repo, root = git_repo_root()
    for adjacent in root.parent.iterdir():
        try:
            repo, root = git_repo_root(adjacent)
        except InvalidGitRepository:
            pass
        else:
            remotes = set(_parsed_remotes(repo))
            if any(CLOUD_CITY_GITLAB_URI in r.path or CLOUD_CITY_GITLAB_URI in r.hostname for r in remotes):
                if len(remotes) > 1:
                    raise BespinctlError(f"Cloud City git repo at {root} has multiple remotes, which is unsupported in bespinctl: {sorted(remotes)}")
                yield repo, root, remotes.pop()


@cache
def git_repo_root(path: Path | str | None = None) -> tuple[Repo, Path]:
    from bespin_tools.lib.logging import logger # Local import to avoid import loops
    import git

    if path is None:
        path = __file__
    try:
        path = resolve_readable(path)
    except BespinctlError as ex:
        raise InvalidGitRepository(path) from ex

    logger.debug(f"{path}: checking for git repo...")

    try:
        git_repo = git.Repo(path, search_parent_directories=True)
    except git.GitCommandError as ex:
        if 'must be run in a work tree' in str(ex).lower():
            raise InvalidGitRepository(path) from ex
        raise
    except git.InvalidGitRepositoryError as ex:
        raise InvalidGitRepository(path) from ex

    return git_repo, Path(git_repo.git.rev_parse("--show-toplevel")).resolve()
