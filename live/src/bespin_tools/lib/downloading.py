from __future__ import annotations

from asyncio import current_task
from functools import cache
from io import BytesIO
from tarfile import TarFile
from typing import Iterable
from zipfile import ZipFile

import aiohttp
import requests
from tqdm import tqdm

from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.network import probe_url
from bespin_tools.lib.util import stream_results


def _extract(buf):
    return TarFile.open(fileobj=buf, mode="r")

@cache
def decompressors():
    return (
        ('.tar.xz', _extract),
        ('.zip', lambda buf: ZipFile(buf, "r")),
        ('.tar.gz', _extract),
        ('.tgz', _extract),
        ('.tar.bzip2', _extract),
        ('.tar', _extract),
    )


async def first_live_url(urls: Iterable[str]) -> str:
        async for res in stream_results(probe_url(url) for url in set(urls)):
            if res is not None and not isinstance(res, Exception):
                return res
        raise BespinctlError(f"No valid URLs found in {sorted(urls)}")

def download_file(url, chunk_size=8192) -> BytesIO:
    buffer = BytesIO()
    with requests.get(url, stream=True, timeout=1800) as response:
        response.raise_for_status()
        # https://stackoverflow.com/questions/37573483/progress-bar-while-download-file-over-http-with-requests
        total_size = int(response.headers.get("content-length", 0))
        with tqdm(total=total_size, unit="B", unit_scale=True, desc=f"download: {url}") as progress_bar:
            for chunk in response.iter_content(chunk_size=chunk_size):
                progress_bar.update(len(chunk))
                buffer.write(chunk)
    buffer.seek(0)
    return buffer
