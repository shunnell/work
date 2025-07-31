from __future__ import annotations

from functools import cache
from pathlib import Path
from subprocess import check_output

from bespin_tools.lib.cache import terragrunt_terraform_module_cache, terraform_provider_cache
from bespin_tools.lib.command.downloaded import DownloadedCommand
from bespin_tools.lib.iac import iac_tool_versions
from bespin_tools.lib.util import WINDOWS


@cache
def terraform() -> DownloadedCommand:
    """
    Retrieve the command for "terraform", since terragrunt needs it internally.
    """
    return DownloadedCommand(
        name='terraform',
        source_uri_template='https://releases.hashicorp.com/{name}/{version}/{name}_{version}_{os}_{architecture}{suffix}',
        version_constraints=iac_tool_versions()['terraform']
    )

@cache
def terraform_docs() -> DownloadedCommand:
    """
    Retrieve the command for "terraform-docs"
    """

    # Terraform-docs' version output is in a weird output format, do a custom parse for it:
    class TerraformDocsCommand(DownloadedCommand):
        def _get_version(self, cmd: Path) -> str:
            cmd = (cmd, '--version')
            output: bytes = check_output(cmd, shell=False)
            parts = tuple(s.lower() for s in output.decode().split())
            return parts[parts.index('version') + 1]

    return TerraformDocsCommand(
        name='terraform-docs',
        source_uri_template='https://github.com/{name}/{name}/releases/download/v{version}/{name}-v{version}-{os}-{architecture}{suffix}',
        version_constraints=iac_tool_versions()['terraform-docs'],
    )


@cache
def _terragrunt() -> DownloadedCommand:

    suffix = '.exe' if WINDOWS else ''
    rv = DownloadedCommand(
        name='terragrunt',
        source_uri_template='https://github.com/gruntwork-io/{name}/releases/download/v{version}/{name}_{os}_{architecture}' + suffix,
        version_constraints=iac_tool_versions()['terragrunt']
    )
    # Per Terragrunt docs, this Terraform variable is not safe to set when using Terragrunter:
    rv.env.pop('TF_PLUGIN_CACHE_DIR', None)
    return rv

def terragrunt() -> DownloadedCommand:
    """
    Retrieve the command for "terragrunt", automatically downloading it if needed, since it's needed for all our IAC
    operations.
    """
    # Prime the terraform cache as well so errors related to terraform are surfaced here rather than from inside
    # terragrunt in more confusing ways.
    terraform_cmd = terraform()

    # TODO https://terragrunt.gruntwork.io/docs/reference/cli-options/#source-map
    # NB: docs and the internet *say* that 'true' is just as good as '1' for the values on these, but examples
    # and documentation quality vary wildly; it's within reason that specific true/1/etc. values turn out to
    # be needed for specific variables. Don't assume things are consistent if you see errors; try different
    # values instead.
    terragrunt_env_vars = {
        # TODO PATH stripping?
        'TG_NO_AUTO_INIT': False,
        'TG_SOURCE_UPDATE': False,
        'TG_STRICT_MODE': True,
        'TG_STRICT_VALIDATE': True,
        'TG_NO_AUTO_APPROVE': True,  # Prevent foot-guns
        # Potentially reduces situations where the logging system's computation of relative paths will trip Windows
        # max-path-length limits:
        'TG_LOG_SHOW_ABS_PATHS': True,
        'TG_TF_FORWARD_STDOUT': True,
        'TG_TF_PATH': terraform_cmd.path,
        'TG_DOWNLOAD_DIR': terragrunt_terraform_module_cache(),
        # # If it can't find the state bucket (which should always exist), abort because something is wrong:
        'TG_BACKEND_REQUIRE_BOOTSTRAP': True,
        # Always use the same cache settings so multiple invocations can share the cache server.
        'TG_PROVIDER_CACHE': True,
        'TG_PROVIDER_CACHE_DIR': terraform_provider_cache(),
    }
    cmd = _terragrunt()
    cmd.env = cmd.env.copy()
    cmd.env.update({
        k: str(v).lower() if isinstance(v, bool) else str(v) for k, v in terragrunt_env_vars.items()
    })


    return cmd
