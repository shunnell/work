from __future__ import annotations

import itertools
import re
from functools import cache
from pathlib import Path
from typing import Iterable

import hcl2
from git import InvalidGitRepositoryError
from packaging.specifiers import Specifier

from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.git_repo import git_repo_root, cloud_city_repos
from bespin_tools.lib.logging import logger
from bespin_tools.lib.util import iterdir

_IAC_REPO_PATHS = (
    'cloud-city/platform/iac/live',
    'cloud-city/platform/iac/modules',
    'cloud-city/platform/iac/kubernetes',
)

def _iac_files_iter(below: Path) -> Iterable[Path]:
    for path in iterdir(below):
        if path.parts[-1] == '.terragrunt-cache':
            yield path
        elif '.terragrunt-cache' not in path.parts and path.suffix in ('.tf', '.hcl'):
            yield path


def iac_repos():
    returned = False
    for repo, root, url in cloud_city_repos():
        if url.path.removesuffix('.git').endswith(_IAC_REPO_PATHS):
            returned = True
            yield repo, root
    if not returned:
        raise BespinctlError('No IAC repos found')


def iac_files(below: Path, ignored: bool=False, only_suffix: str | None = None) -> Iterable[Path]:
    repo = git_repo_root(below)[0]
    for paths in itertools.batched(_iac_files_iter(below), 100):
        # Check repo.ignored in batches because it is very slow otherwise:
        ignored_paths = map(Path, repo.ignored(*paths))
        if ignored:
            yieldfrom = ignored_paths
        else:
            paths = set(paths)
            paths.difference_update(ignored_paths)
            yieldfrom = paths
        for path in yieldfrom:
            if only_suffix is None or path.suffix == only_suffix:
                yield path

@cache
def iac_tool_versions() -> dict:
    root = git_repo_root()[1]
    root_hcl = hcl2.loads(root.joinpath('root.hcl').read_text())
    rv = {'terraform-docs': '==0.20.0'}
    for tool in ('terragrunt', 'terraform'):
        version_selector = re.search('\\d+.*$', root_hcl[f"{tool}_version_constraint"]).group()
        rv[tool] = f"=={version_selector}"
    # Validate and return
    return {k: str(Specifier(v)) for k, v in rv.items()}


def setup_global_logger_for_terragrunt():
    prefix = None
    try:
        repo_root = git_repo_root()[1]
        cwd = Path.cwd().resolve()
        if cwd.is_relative_to(repo_root):
            path = cwd.relative_to(repo_root)
            if str(path) != ".":
                prefix = f"{repo_root.name}/{path}"

    except InvalidGitRepositoryError:
        pass
    if prefix is not None:
        logger.change_prefix(prefix, append=False)
