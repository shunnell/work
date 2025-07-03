from __future__ import annotations

from functools import wraps
from inspect import isgeneratorfunction
from typing import TYPE_CHECKING

from bespin_tools.lib import replaceall

CLOUD_CITY_ORGANIZATION_ROOT_ACCOUNT = '590183957203'
CLOUD_CITY_ORGANIZATION_ID = 'o-9cdv0jbn8r'
CLOUD_CITY_ORGANIZATION_ROOT_CONTAINER = 'r-ikpg'

if TYPE_CHECKING:
    from typing import Callable, ParamSpec, TypeVar, Iterable
    _P = ParamSpec("_P")
    _T = TypeVar("_T")

def _error_matches(errors: Iterable[str], ex: Exception) -> bool:
    from bespin_tools.lib.logging import debug

    # Runtime import to avoid overhead: boto is very heavy to load
    from botocore.exceptions import ClientError
    if not isinstance(ex, ClientError):
        return False

    for part in replaceall(str(ex), ":()", " ").split():
        if part in errors:
            debug(f"Suppressing (for rule '{part}') boto error: {ex}")
            return True
    return False


def suppress_boto_error(
    errors: str | Iterable[str],
):
    errcheck = set()
    for error in (errors,) if isinstance(errors, str) else errors:
        assert error.isalnum(), f"Bad error string: {error}"
        errcheck.add(error)

    def decorator(func: Callable[_P, _T]) -> Callable[_P, _T | None]:
        if isgeneratorfunction(func):
            @wraps(func)
            def inner(*args: _P.args, **kwargs: _P.kwargs):
                try:
                    yield from func(*args, **kwargs)
                except Exception as ex:
                    if not _error_matches(errcheck, ex):
                        raise
        else:
            @wraps(func)
            def inner(*args: _P.args, **kwargs: _P.kwargs):
                try:
                    return func(*args, **kwargs)
                except Exception as ex:
                    if not _error_matches(errcheck, ex):
                        raise
        return inner
    return decorator
