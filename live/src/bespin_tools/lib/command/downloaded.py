from __future__ import annotations

import asyncio
import itertools
import platform
import shutil
import stat
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

import attr
from packaging.version import Version

from bespin_tools.lib.cache import cached_binary
from bespin_tools.lib.command.base import BaseCommand
from bespin_tools.lib.downloading import download_file, first_live_url, decompressors
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.util import WINDOWS


@attr.define()
class DownloadedCommand(BaseCommand):
    """
    Class which represents a CLI command which will be downloaded from the internet and cached by bespinctl.
    """
    source_uri_template: str = attr.field(kw_only=True)

    def _resolve(self):
        exc_class = type(self._exc(''))
        with cached_binary(self.name) as cached_path:
            try:
                rv = self._validate_local_executable(cached_path)
            except exc_class as ex:
                cached_path.unlink(missing_ok=True)
                self._logger.info(f"not available in cache, attempting to download: {ex}")
                self._download_best_and_decompress(cached_path)
                cached_path.chmod(cached_path.stat().st_mode | stat.S_IEXEC)
                rv = self._validate_local_executable(cached_path)
            return rv

    def _candidate_versions(self):
        versions = []
        # Looks weird, but deals with negative constraints:
        for specifier in self.version_constraints:
            if specifier.version in self.version_constraints:
                versions.append(Version(specifier.version))
        BespinctlError.invariant(
            len(versions) > 0,
            f"No valid versions exist in constraint {self.version_constraints}; version_constraints must be set to a valid value"
        )
        versions.sort(reverse=True)  # Start with highest version
        return tuple(versions)

    def _candidate_urls(self):
        osnames = [sys.platform]
        suffixes = [d[0] for d in decompressors()]
        if WINDOWS:
            suffixes.append('.exe')  # Uncompressed .exes for windows
            osnames = ('windows', 'win32')
        else:
            suffixes.append('')  # Raw binaries for UNIX
        architectures = [platform.machine().lower()]
        if architectures[0] in ('x86_64', 'amd64'):
            architectures = ('x86_64', 'amd64')
        elif architectures[0].startswith('arm'):
            architectures = ['arm64']  # TODO?

        for osname, arch, version, suffix in set(itertools.product(osnames, architectures, self._candidate_versions(), suffixes)):
            BespinctlError.invariant(
                isinstance(version, Version),
                f"Only Version objects are allowed for {type(self)}; got {type(version)} {version}",
            )
            yield self.source_uri_template.format(
                name=self.name,
                os=osname,
                version=version,
                architecture=arch,
                suffix=suffix,
            )

    def _download_best_and_decompress(self, target: Path):
        # Retrieve the local file path from the URL, e.g. https://foo.com/bar.zip -> bar.zip
        url = asyncio.run(first_live_url(self._candidate_urls()))
        remote_name = Path(unquote(urlparse(url).path)).name
        for extension, decompressor in decompressors():
            if remote_name.endswith(extension):
                self._logger.info(f"Downloading from {url}")
                buffer = download_file(url)
                self._logger.info(f"Extracting {target.name} from {url} to {target}")
                with decompressor(buffer) as extract_fh:
                    extract_fh.extract(target.name, target.parent)
                    return

        self._logger.info(f"Downloading from {url}")
        buffer = download_file(url)

        self._logger.info(f"Writing uncompressed binary data from {url} to {target}")
        with open(target, 'wb') as fh:
            shutil.copyfileobj(buffer, fh)
