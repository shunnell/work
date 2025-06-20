from __future__ import annotations

import email.utils
from pathlib import Path

import click
import pytest

from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.iac import setup_global_logger_for_terragrunt
from bespin_tools.lib.git_repo import cloud_city_repos, git_repo_root
from bespin_tools.lib.iac.commands import terragrunt as terragrunt_command, terraform as terraform_command
from bespin_tools.lib.iac.linting import lint_tf_files, lint_terraform_module_docs, lint_hcl_files
from bespin_tools.lib.logging import attention
from bespin_tools.lib.util import resolve_file
from bespin_tools.lib.windows import try_to_fix_windows_max_path_length

INFRA_ACCOUNT_ID = '381492150796'
TERRAGRUNTER_ROLE = f"arn:aws:iam::{INFRA_ACCOUNT_ID}:role/terragrunter"

@click.group()
def iac():
    """
    Commands for manipulating Cloud City infrastructure-as-code using Terragrunt.
    """
    setup_global_logger_for_terragrunt()
    try_to_fix_windows_max_path_length()
    Organization.start_priming_common_client_cache()

@iac.command(
    short_help="Pre-configures all AWS access, validates environment/settings, then runs 'terragrunt' with all arguments passed through to it.",
    context_settings=dict(
        help_option_names=(),
        ignore_unknown_options=True,
    ),
)
@click.argument('args', nargs=-1, type=click.UNPROCESSED)
def terragrunt(args):
    """
    Runs terragrunt in an environment that is correctly connected to AWS IAM and has passed several sanity checks
    to ensure that terragrunt functions correctly.
    """
    # If users are trying to read help messages or get terragrunt versions, skip IAM setup (it takes time, can fail)
    # and run the subcommand straight away. This helps them easily debug version/installation issues (and is especially
    # necessary if 'terragrunt' is aliased to this subcommand in their shells):
    skip_role_assume = args == () or any(x in args for x in ('--help', '--version', '-h', '-v'))
    cmd = terragrunt_command()

    if not skip_role_assume:
        infra_account, = Organization.get_accounts(INFRA_ACCOUNT_ID)
        sts = infra_account.sts_client()
        identity = sts.get_caller_identity()
        assert identity['Account'] == INFRA_ACCOUNT_ID, f"Invoked from the wrong account: {identity['Account']}"

        if identity['Arn'].startswith((TERRAGRUNTER_ROLE, f"arn:aws:iam::{INFRA_ACCOUNT_ID}:assumed-role/terragrunter")):
            attention(f"Already running as infra terragrunter role; no need to assume role: {identity['Arn']}")
            new_env = infra_account.environment_variables()
        else:
            base, prior_role = identity['Arn'].rsplit(':', 1)
            try:
                _, addr = prior_role.rsplit('/', 1)
                email.utils.parseaddr(addr, strict=True)
                assert addr.endswith('@state.gov')
            except Exception as ex:
                raise BespinctlError(f"Unexpected format of bootstrap human user role; must end with an email: {prior_role}") from ex
            new_env = infra_account.environment_variables(assume_role=(TERRAGRUNTER_ROLE, f'bespinctl.{addr}',))
        cmd.env.update(new_env)

    # Prevent foot-guns at apply time unless a user explicitly requested it:
    if '-auto-approve' in args or '--auto-approve' in args:
        cmd.env['TG_NO_AUTO_APPROVE'] = 'false'

    # TODO enumerate terragrunt subcommands and write a test to ensure we don't drift, then we can have specific handling
    #   for e.g. init vs apply etc.
    cmd.run(*args)

@iac.command(context_settings=dict(
    help_option_names=(),
    ignore_unknown_options=True,
))
@click.argument('args', nargs=-1, type=click.UNPROCESSED)
def terraform(args):
    """Runs 'terraform' and passes all arguments through to that command.
    This should rarely be used; prefer using `bespinctl iac terragrunt` instead.
    """
    terraform_command().run(*args)

@iac.command
@click.option('--fix', is_flag=True, default=False, help="Whether to automatically fix linting errors. If not set, this command will fail when it sees the first linter error.")
@click.option('--all-repos', is_flag=True, default=False, help="Whether to lint all Cloud City IaC-related repos. If not set, this command will lint files below the current working directory.")
def lint(fix: bool, all_repos: bool):
    if all_repos:
        paths = (p[1] for p in cloud_city_repos())
    else:
        paths = [Path('.')]
    for path in paths:
        lint_tf_files(path, fix)
        lint_terraform_module_docs(path, fix)
        lint_hcl_files(path, fix)

@iac.command
@click.option('--account', help="AWS Account ID in which to bootstrap the terragrunter user")
@click.argument('action', type=click.Choice(['plan', 'apply']))
def bootstrap_new_aws_account(account: str, action: str):
    """
    Creates the bare minimum AWS entities needed to run 'terragrunter' IaC against an AWS account. Should only be run
    once, after a brand new AWS account is created per https://confluence.fan.gov/display/CCPL/New+AWS+Account+Creation
    """
    cmd = terragrunt_command()
    repo_root = git_repo_root()[1]
    config_path = resolve_file(repo_root.joinpath('_envcommon/bootstrap/bootstrap_terragrunter_in_new_account.hcl'))
    account, = Organization.get_accounts(account)
    cmd.env.update(account.environment_variables())
    # TODO validate top-level account folder exists (and complain/warn if not) once we have structural awareness of that.
    cmd.run("--experiment", "cli-redesign", "run", "--config", config_path, action)

@iac.command
def test():
    # Run pytest on selected folders for IAC testing.
    pytest.main(['management'])
