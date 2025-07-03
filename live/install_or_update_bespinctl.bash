#!/usr/bin/env bash

current_shell=$(ps -p $$ -o comm= | sed 's/^-//')
# Check if we're running in bash first
if [ -z "$BASH_VERSION" ]; then
  shell_name=$(basename "$current_shell")
  echo "Error: This script requires bash." >&2
  echo "Error: Current shell: $shell_name" >&2
  exit 1
fi

# Then check bash version is newer than 4.4
if [[ ! "$BASH_VERSION" =~ ^([5-9]\.|4\.[4-9]) ]]; then
  echo "Error: This script requires bash 4.4 or newer." >&2
  echo "Error: Currently using bash version $BASH_VERSION" >&2
  exit 1
fi

if [[ "${DOS_CLOUD_CITY_BESPINCTL_DEBUG:-0}" != 0 ]]; then
  echo "Running '${0}' in debug mode..." &>2
  set -x
fi

set -euo pipefail

# https://stackoverflow.com/questions/59895
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
if [[ ! -f "$SCRIPT_DIR/pyproject.toml" ]]; then
  _print "Error: Could not find bespinctl root config at $SCRIPT_DIR/pyproject.toml; aborting."
  exit 1
fi

export WINDOWS=0
if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  export WINDOWS=1
elif command -v powershell.exe 2>&1 >/dev/null; then
  export WINDOWS=1
fi

_print() {
  echo -e "$@" >&2
}

_command_path() {
  # cmd, variable, linux fallback, windows fallback
  local cmd="${1:?command not set}"
  local variable="${2:?variable not set}"
  local path
  if command -v "$cmd" >/dev/null 2>&1; then
    path=$(command -v "$cmd")
  elif [[ $WINDOWS == 1 ]]; then
    if command -v "$cmd.exe" >/dev/null 2>&1; then
      path=$(command -v "$cmd.exe")
    else
      path=${4:?windows fallback not set}
    fi
  else
    path=${3:?linux fallback not set}
  fi
  if [[ -n "$path" ]] && [[ -x "$path" ]]; then
    export "${variable}"="$path"
    return 0
  else
    return 1
  fi
}

_suppress_specific_error() {
  local suppress_error=$1
  shift
  local result
  local exitstatus
  set +e
  result=$("$@" 2>&1)
  exitstatus=$?
  set -e
  if [[ $exitstatus -ne 0 ]] && [[ "${result^^}" != *"${suppress_error^^}"* ]]; then
    _print "Command '$*' errored:\n${result}" 2>&1
    return $exitstatus
  fi
  return 0
}

if ! _command_path uv UV_COMMAND "~/.local/bin/uv" "$HOME\.local\bin\uv.exe"; then
  _print "'uv', the Python runtime manager for bespinctl, is not installed. Press 'y' to install it manually, or abort/answer 'n'"
  _print "and use your system package manager to install it (e.g. 'brew install uv' or 'apt-get install uv')."
  _print "Additional installation instructions available at: https://docs.astral.sh/uv/getting-started/installation/"

  if [[ $WINDOWS == 1 ]]; then
    uv_install='powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"'
  else
    uv_install='command curl -LsSf https://astral.sh/uv/install.sh | sh'
  fi

  # https://stackoverflow.com/questions/1885525/
  read -p "Install 'uv' (command: '${uv_install}') Y/N? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    eval "$uv_install"
    if ! _command_path uv UV_COMMAND "~/.local/bin/uv" "$HOME\.local\bin\uv.exe"; then
      _print "'uv' installation reported success, but tool is not yet available. Try restarting your shell and try again."
      exit 1
    fi
  else
    _print "Error: Aborted!"
    exit 1
  fi
fi

_print "Found 'uv' at '${UV_COMMAND}; checking version..."
"$UV_COMMAND" --version
# Cache-clean twice, once before self-update (in case self-update is broken due to poisoned cache) and again afterwards
# (in case self update changed the way the cache works).
_suppress_specific_error "no cache" "$UV_COMMAND" cache clean
# If uv was installed externally, it produces an error here which can be ignored:
_suppress_specific_error "package manager" "$UV_COMMAND" self update
_suppress_specific_error "no cache" "$UV_COMMAND" cache clean
_suppress_specific_error "no cache" "$UV_COMMAND" cache prune

# The project is called bespin-tools, but some iterations of it on some platforms might be called "bespinctl"?
# No idea why that is, but safe to remove both regardless; we then install directly from the path rather than the
# project name.
for item in bespin-tools bespinctl; do
  _suppress_specific_error "not installed" "$UV_COMMAND" tool uninstall "$item"
done

"$UV_COMMAND" tool install --force -e "$SCRIPT_DIR"

"$UV_COMMAND" tool update-shell

if _command_path rye RYE_COMMAND "/dev/null/nothing" "/dev/null/nothing"; then
  _print "'rye' is installed, which is no longer needed for bespinctl"
  _print "If you're not using rye for anything else, consider uninstalling it via your package manager or 'rye self uninstall'"
fi

_print "Clearing bespinctl caches..."
"$UV_COMMAND" tool run --from bespin-tools bespinctl clear-caches --execute
_print "bespinctl was successfully installed (you may need to restart your shell to be able to use it)!"
