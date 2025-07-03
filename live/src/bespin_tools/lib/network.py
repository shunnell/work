from asyncio import current_task, TimeoutError
from datetime import timedelta

from aiohttp import ClientSession, ClientTimeout
from aiohttp.client_exceptions import ClientError, ConnectionTimeoutError

async def probe_url(
        url: str,
        timeout: ClientTimeout | timedelta | float=5,
        **kwargs,
) -> str | ClientError:
    if isinstance(timeout, timedelta):
        timeout = timedelta.total_seconds()
    if not isinstance(timeout, ClientTimeout):
        assert timeout > 0
        timeout = ClientTimeout(total=timeout)

    try:
        async with ClientSession(timeout=timeout) as session, session.head(url, **kwargs) as response:
            await response.read()
            response.raise_for_status()
            return url
    except Exception as ex:
        if task := current_task():
            if task.cancelled() or task.cancelling():
                return "<cancelled>" # Ignored
        # aiohttp has a bug where it returns raw asyncio.TimeoutError objects instead of built-in errors sometimes:
        if isinstance(ex, TimeoutError):
            ex = ConnectionTimeoutError()
        if isinstance(ex, ClientError):
            return ex
        raise
