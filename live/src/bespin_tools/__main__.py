from __future__ import annotations

import sys

sys.dont_write_bytecode = True  # Prevent use of __pycache__ and .pyc files, they don't benefit this kind of program.

from functools import cache
from types import ModuleType
from collections import defaultdict
from importlib import import_module
from pathlib import Path

from click import Group, BaseCommand

from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.python_files import python_modules


@cache
def _entry_point_details() -> tuple[Group, str, ModuleType]:
    """
    Returns a tuple of:
        1. The root Click entry point function.
        2. The executable name under which this script was invoked (i.e. "bespinctl", or one of the other entries in
           project.scripts in pyproject.toml).
        3. The module containing the root Click entry point function.
    """
    import bespin_tools.commands
    root_command = bespin_tools.commands.bespinctl
    executable_name = Path(sys.argv[0]).name.removesuffix(".exe")
    if not isinstance(root_command, Group):
        raise BespinctlError(f"Root command {root_command} (at {root_command.__qualname__}) is not a click.Group")
    return root_command, executable_name, bespin_tools.commands

def _launch_from_executable(commands: dict[str, list[list[str]]]):
    root_command, executable_name, _ = _entry_point_details()
    BespinctlError.invariant(
        executable_name in commands,
        f"Cannot invoke CLI; entry point '{executable_name}' not found in any subcommands",
    )
    argv, *rest = commands[executable_name]
    if len(rest) > 0:
        collisions = ", ".join(f"'{' '.join(f)} {executable_name}'" for f in commands[executable_name])
        raise BespinctlError(f"Cannot invoke CLI with ambiguous entry point '{executable_name}'; could mean any of {collisions}")

    program_name = None
    if len(argv) > 0:
        argv.append(executable_name)
        program_name = f"{executable_name} (via bespinctl)"
    argv.extend(sys.argv[1:])
    return root_command(args=argv, prog_name=program_name)


def main() -> None:
    """
    Main entry point for bespinctl's CLI interface. This is a bit weird and unusual by Python CLI standards, and thus
    bears some explanation. This code serves several purposes:

    1. Bespinctl's CLI is a Click (https://click.palletsprojects.com/en/stable/) application. The main Click entry point
       is contained in the adjacent commands/__init__.py. All the bespinctl subcommands and groups descend from that.
       all commands/subcommands/groups in bespinctl's Click tree are defined somewhere below the bespin_tools/commands
       folder. The stuff in those files is regular Click application code, with one minor difference from standard
       practice: normally, a Click subcommand is implemented by defining a click.group object in some file, and then
       having the "parent" command of the subcommand import that group and attach it to the parent group via
       "parent_group.add_command(subcommand)". Bespinctl does not follow that convention: files in bespin_tools.commands
       should *not* import other files in that tree for purposes of calling "add_command". Instead, "add_command" on all
       subcommand files containing Click.Group objects (@click.group decorators) is performed automatically by the below
       code. If new code is added that does attempt to use the traditional pattern, an error will be emitted suggesting
       that manual add_command() calls not be used.
    2. In service to 1., the below code iterates and automatically imports all files below "bespin_tools.commands". This
       means that code written in that hierarchy needs to be careful not to do anything that takes a lot of time
       at compile time (huge imports or top-level computations that do significant work). If any subcommand module does
       that (or imports anything that does that), the startup time of all of bespinctl will suffer.
    3. Bespinctl also has "executable aliases": in pyproject.toml, multiple scripts are defined which point to this
       function. "bespinctl" is one of them, but so are e.g. "terraform" and "terragrunt". When this package is
       installed, symlinks/launcher stubs are created for each of those names. When bespinctl is launched from one of
       those other stubs, the launcher is name-aware: if there is one (and only one) click.command anywhere in the
       Click command hierarchy under "bespin_tools.commands" whose name matches the name under which bespinctl was
       launched, that command will be run directly. In other words, if bespinctl installs a project.scripts entry for
       this function like '"foobar" = "bespin_tools.__main__:main"', and there exists a subcommand of bespinctl like
       'bespinctl iac foobar' or 'bespinctl toolbox mytool foobar', then that command will be called directly whenever
       a user calls "foobar" on the commandline. This works just like a shell alias, but is an actual executable program
       on the PATH, so a shell isn't needed in order to launch it. This behavior exists to support external tools which
       want to run e.g. "terraform" as an executable on PATH: such tools can now run in an environment which has
       bespinctl installed, and bespinctl will then download and run the appropriate version of "terraform" on the
       command line without such tools (hopefully) having to know that bespinctl is in the mix at all.
          - This approach is similar to the one taken by busybox: https://busybox.net/downloads/BusyBox.html
          - Note that when adding a project.scripts alias, the key should be the command name, which can differ from
            the name of the Python function that defines the command (e.g. a @click.command decorator on 'def foo_bar()'
            will create a command named 'foo-bar', not 'foo_bar').
    """
    root_command, _, root_module = _entry_point_details()
    groups_by_module = {}
    commands = defaultdict(list)

    for module_name in python_modules(root_module):
        mod = import_module(module_name)
        for item in (getattr(mod, i) for i in dir(mod)):
            if isinstance(item, Group):
                groups_by_module[module_name] = item
                parent_module = module_name.rsplit('.', 1)[0]
                if parent_module in groups_by_module:
                    groups_by_module[parent_module].add_command(item)
                elif item != root_command:
                    raise BespinctlError(f"Could not add command group '{item.name}' as its parent module '{parent_module}' was not found. This is likely caused by changes below {root_module.__name__} calling 'click.add_command()' on an imported subcommand; that should never be done in this codebase, as it is done automatically in __main__.py.")
            if isinstance(item, BaseCommand):
                subcommand_path = module_name.removeprefix(root_module.__name__).split(".")
                subcommand_path = list(filter(None, subcommand_path))
                commands[item.name].append(subcommand_path)
    _launch_from_executable(commands)

if __name__ == "__main__":
    main()
