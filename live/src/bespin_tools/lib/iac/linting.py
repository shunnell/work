from __future__ import annotations

from collections import defaultdict
from functools import cache
from pathlib import Path

from tqdm import tqdm

from . import iac_files
from .commands import terragrunt, terraform, terraform_docs
from ..logging import logger


@cache
def _directories_with_tf_files(below: Path) -> tuple[tuple[Path, bool]]:
    """
    Returns an iterator that yields directories that contain at least one .tf file. The boolean corresponds to whether
    or not bespinctl thinks that directory is an importable Terraform module (indicated by the absence of .hcl files).
    """
    rv = []
    dirs = defaultdict(list)
    for path in iac_files(below):
        if path.is_file():
            dirs[path.parent].append(path)
    for k, v in dirs.items():
        if any(p.suffix == '.tf' for p in v):
            assert k.is_dir()
            rv.append((k, not any(p.suffix == '.hcl' for p in v)))
    return tuple(rv)


def lint_terraform_module_docs(below: Path, fix: bool):
    args = ('--output-file', 'README.md') if fix else ('--output-check',)
    cmd = terraform_docs()

    for path in tqdm(
        sorted(p for p, ismod in _directories_with_tf_files(below) if ismod),
        desc="terraform-docs"
    ):
        cmd.run('markdown', 'table', path, '--lockfile=false', *args)


def lint_tf_files(below: Path, fix: bool):
    for _ in iac_files(below, only_suffix='.tf'):
        args = () if fix else ('-check',)
        terraform().run('fmt', '-diff', '-recursive', *args)
        break
    else:
        logger.info(f'No .tf files found in {below}; not running "terraform fmt"')


def lint_hcl_files(below: Path, fix: bool):
    # Terragrunt's "hclfmt" command has a bug wherein it ignores files not called terragrunt.hcl, which causes later
    # 'terragrunt hclvalidate' to fail.
    hcl_found = False
    lint_individually = []
    for path in iac_files(below, only_suffix='.hcl'):
        hcl_found = True
        if path.name != 'terragrunt.hcl' and path.is_file():
            lint_individually.append(path)
    lint_individually.sort()

    if not hcl_found:
        logger.info(f'No .hcl files found in {below}; not running "terragrunt hclfmt"')
        return

    args = ['hclfmt', '--diff']
    if not fix:
        args.append('--check')
    cmd = terragrunt()

    with cmd._logger.temporary_level('ERROR'):
        cmd.run(*args)  # Lint all the terragrunt.hcl files recursively

        # Lint the ones with different names, which hclfmt leaves out:
        for path in tqdm(lint_individually, desc='terragrunt hclfmt'):
            cmd.run('hclfmt', *args, path)
    # Run validation on all files (which doesn't need the non-terragrunt.hcl ones called out):
    cmd.run('hclvalidate', '--log-level', 'error')  # TODO more centrally manage loglevel tied to bespinctl's
