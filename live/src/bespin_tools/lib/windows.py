import ctypes
from functools import cache
from sys import exc_info

from bespin_tools.lib.logging import warn, error, info, success, debug
from bespin_tools.lib.util import WINDOWS

_LONG_PATH_REGKEY = ("HKLM", "SYSTEM\\CurrentControlSet\\Control\\FileSystem", "LongPathsEnabled")

def _windows_process_is_long_path_enabled():
    ntdll = ctypes.WinDLL('ntdll')
    funcname = "RtlAreLongPathsEnabled"
    if hasattr(ntdll, funcname):
        ntdll.RtlAreLongPathsEnabled.restype = ctypes.c_ubyte
        ntdll.RtlAreLongPathsEnabled.argtypes = ()
        return bool(ntdll.RtlAreLongPathsEnabled())
    warn(f"Could not check if Windows long paths are available for this process; {funcname} is not available")

def _use_windows_long_path_registry_key(value: bool | None):
    import winreg
    key = None

    try:
        key = winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE,
            _LONG_PATH_REGKEY[1],
            0,
            winreg.KEY_READ if value is None else winreg.KEY_WRITE
        )
        if value is None:
            return bool(winreg.QueryValueEx(key, _LONG_PATH_REGKEY[-1])[0])
        else:
            winreg.SetValueEx(key, _LONG_PATH_REGKEY[-1],0, winreg.REG_DWORD, int(value))
            return value
    except OSError as registry_error:
        debug("Error communicating with registry", exc_info=registry_error)
        error(f"Could not {'read' if value is None else 'write'} registry key {'\\'.join(_LONG_PATH_REGKEY)}: {registry_error}")
    finally:
        if key is not None:
            winreg.CloseKey(key)

def _check_admin_privileges():
    if not WINDOWS:
        return False
    
    try:
        return bool(ctypes.windll.shell32.IsUserAnAdmin())
    except:
        return False

@cache
def try_to_fix_windows_max_path_length():
    if not WINDOWS:
        return
    
    if _windows_process_is_long_path_enabled() or _use_windows_long_path_registry_key(None):
        info("Windows long path support is enabled")
        return
    
    warn("Long path support is disabled on windows, attempting to fix")
    
    if _check_admin_privileges():
        if _use_windows_long_path_registry_key(value=True):
            success(f"Enabled windows long path support in the registry ({'\\'.join(_LONG_PATH_REGKEY)} = 1)")
        else:
            debug(f"Failed to update Windows long path registry setting")
            warn(f"To enable long path support manually, set {'\\'.join(_LONG_PATH_REGKEY)} to 1 (DWORD) in the Windows Registry")
    else:
        warn(f"Long path support is disabled and couldn't be fixed (non-admin mode)")
        warn(f"To enable long path support manually, set {'\\'.join(_LONG_PATH_REGKEY)} to 1 (DWORD) in the Windows Registry or run in an elevated shell")