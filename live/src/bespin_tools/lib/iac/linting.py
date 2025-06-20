from __future__ import annotations

from collections import defaultdict
from functools import cache
from pathlib import Path
from typing import Collection

from tqdm import tqdm

from . import iac_files
from .commands import terragrunt, terraform, terraform_docs
from ..errors import BespinctlError
from ..logging import logger


@cache
def _directories_with_tf_files(below: Path) -> Collection[tuple[Path, bool]]:
    """
    Returns an iterator that yields directories that contain at least one .tf file. The boolean corresponds to whether
    or not bespinctl thinks that directory is an importable Terraform module (indicated by the absence of .hcl files).
    """
    rv = dict()
    for path in iac_files(below, only_suffix='.tf'):
        path = path.parent
        rv[path] = not any(p.suffix == '.hcl' for p in path.iterdir())
    if len(rv) == 0:
        logger.warning(f'No .tf files found in {below}; not running "terraform fmt"')
    return tuple(sorted(rv.items()))


def lint_terraform_module_docs(below: Path, fix: bool):
    args = ('--output-file', 'README.md') if fix else ('--output-check',)
    cmd = terraform_docs()
    for path, ismod in tqdm(_directories_with_tf_files(below), desc="terraform-docs"):
        if ismod:
            cmd.run('markdown', 'table', path, '--lockfile=false', *args, quiet=True)


def lint_tf_files(below: Path, fix: bool):
    args = () if fix else ('-check',)
    cmd = terraform()
    for folder, _ in tqdm(_directories_with_tf_files(below), desc="terraform-fmt"):
        cmd.run('fmt', '-diff', *args, cwd=folder, quiet=True)



def lint_hcl_files(below: Path, fix: bool):
    # Terragrunt's "hclfmt" command has a bug wherein it ignores files not called terragrunt.hcl, which causes later
    # 'terragrunt hclvalidate' to fail.
    hcl_found = False
    terragrunt_hcl_found = False
    lint_individually = []
    for path in iac_files(below, only_suffix='.hcl'):
        hcl_found = True
        if path.name == 'terragrunt.hcl':
            terragrunt_hcl_found = True
        elif path.is_file():
            lint_individually.append(path)
    lint_individually.sort()

    if not hcl_found:
        logger.info(f'No .hcl files found in {below}; not running "terragrunt hclfmt"')
        return

    args = ['hclfmt', '--diff']
    if not fix:
        args.append('--check')
    cmd = terragrunt()

    cmd.run(*args)  # Lint all the terragrunt.hcl files recursively
    # Lint the ones with different names, which hclfmt leaves out:
    for idx, path in enumerate(tqdm(lint_individually, desc='terragrunt hclfmt individual files')):
        cmd.run('hclfmt', *args, path, quiet=True)
    if terragrunt_hcl_found:
        # Run validation on all files (which doesn't need the non-terragrunt.hcl ones called out):
        cmd.run('hclvalidate', '--log-level', 'error')  # TODO more centrally manage loglevel tied to bespinctl's
    else:
        logger.info(f'No terragrunt.hcl files found in {below}; not running "terragrunt hclvalidate"')