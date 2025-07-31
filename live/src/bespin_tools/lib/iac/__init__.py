from __future__ import annotations

import itertools
import re
from email.utils import parseaddr
from functools import cache, partial
from pathlib import Path
from typing import Iterable, Literal, Mapping, Collection

import hcl2
import lazy_object_proxy
from packaging.specifiers import Specifier

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.aws.util import is_account_id
from bespin_tools.lib.command.environment import EnvironmentVariables
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.git_repo import git_repo_root, cloud_city_repos, InvalidGitRepository
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

def parse_hcl_file(source: Path) -> Mapping:
    data = hcl2.loads(source.read_text())
    local_vars = dict()
    for block in data.get('locals', []):
        for k, v in block.items():
            BespinctlError.invariant(
                k not in local_vars,
                f"{source}: local variable '{k}' was set more than once",
            )
            local_vars[k] = v
    data['locals'] = local_vars
    return data

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

def environment_with_role_assumed(account_locator: str, role: str) -> EnvironmentVariables:
    _, account = iac_accounts()[account_locator]
    terragrunter_role = f"arn:aws:iam::{account.account_id}:role/{role}"
    identity = account.sts_client().get_caller_identity()
    BespinctlError.invariant(
        identity['Account'] == account.account_id,
        f"Invoked from the wrong account: expected {account.account_id} but got {identity['Account']}",
    )

    if identity['Arn'].startswith((terragrunter_role, f"arn:aws:iam::{account.account_id}:assumed-role/{role}")):
        logger.warning(f"Already running as infra terragrunter role; no need to assume role: {identity['Arn']}")
        new_env = account.environment_variables()
    else:
        base, prior_role = identity['Arn'].rsplit(':', 1)
        error_info = f"{identity['Arn']} ({prior_role})"
        try:
            _, addr = prior_role.rsplit('/', 1)
            parseaddr(addr, strict=True)
            BespinctlError.invariant(
                addr.endswith('@state.gov'),
                f"Current identity is not based on a DoS account: {error_info}",
            )
        except Exception as ex:
            raise BespinctlError(f"Unexpected format of bootstrap human user role; must end with an email: {error_info}") from ex
        infra_account_hcl = git_repo_root()[1].joinpath('infra', 'account.hcl')

        new_env = account.environment_variables(
            role=terragrunter_role,
            session_name=addr,
            external_id=parse_hcl_file(infra_account_hcl)['locals']['terragrunter_external_id']
        )
    return new_env

@cache
def iac_tool_versions() -> Mapping[str, str]:
    root = git_repo_root()[1]
    root_hcl = parse_hcl_file(root.joinpath('root.hcl'))
    rv = {'terraform-docs': '==0.20.0'}
    for tool in ('terragrunt', 'terraform'):
        version_selector = re.search('\\d+.*$', root_hcl[f"{tool}_version_constraint"]).group()
        rv[tool] = f"=={version_selector}"
    # Validate and return
    return {k: str(Specifier(v)) for k, v in rv.items()}

@cache
def iac_accounts(source: Literal['git', 'aws'] = 'git') -> Mapping[str, tuple[str, Account]]:
    BespinctlError.invariant(source == 'git', f"Unsupported source: {source}")
    rv = dict()
    root = git_repo_root()[1]
    for account_hcl_path in root.glob('*/account.hcl'):
        account_data = parse_hcl_file(account_hcl_path)['locals']
        account_id = account_data.get('account_id')
        BespinctlError.invariant('region' in account_data, f"{account_hcl_path}: Region not found in locals: {account_data}")
        BespinctlError.invariant(
            is_account_id(account_id or ""),
            f"{account_hcl_path}: invalid 'account_id' local: {account_data}",
        )
        for k, v in rv.items():
            BespinctlError.invariant(
                account_id not in (k, v),
                f"{account_hcl_path}: account ID {account_id} already in use by account {k} ({v})",
            )
        # Set both the name and account ID for ease of lookup depending on which one the user has handy:
        rv[account_hcl_path.parent.name] = rv[account_id] = (
            account_id,
            lazy_object_proxy.Proxy(partial(Organization.get_account, account_id)),
        )
    return rv

@cache
def iac_tenant_names(source: Literal['git', 'aws'] = 'git') -> Collection[str]:
    BespinctlError.invariant(source == 'git', f"Unsupported source: {source}")
    rv = set()
    root = git_repo_root()[1]
    for team_hcl_path in root.rglob('team.hcl'):
        team_data = parse_hcl_file(team_hcl_path)['locals']
        BespinctlError.invariant('team' in team_data, f"{team_hcl_path}: missing locals.team")
        team: str = team_data['team']
        team_from_tags: str = team_data.get('team_tags', {}).get('team', '<unset>')
        BespinctlError.invariant(
            team_from_tags in ('${local.team}', 'local.team', team),
            f"{team_hcl_path}: locals.team ({team}) != locals.team_tags.team ({team_from_tags}",
        )
        BespinctlError.invariant(
            team.lower() == team,
            f"{team_hcl_path}: locals.team is not lower case: {team}",
        )
        rv.add(team)
    return frozenset(rv)


def setup_global_logger_for_terragrunt():
    prefix = None
    try:
        repo_root = git_repo_root()[1]
        cwd = Path.cwd().resolve()
        if cwd.is_relative_to(repo_root):
            path = cwd.relative_to(repo_root)
            if str(path) != ".":
                prefix = f"{repo_root.name}/{path}"

    except InvalidGitRepository:
        pass
    if prefix is not None:
        logger.change_prefix(prefix, append=False)

