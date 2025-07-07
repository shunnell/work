from __future__ import annotations

from concurrent.futures import ThreadPoolExecutor, as_completed
from contextlib import ExitStack
from functools import cache
from threading import current_thread
from typing import TYPE_CHECKING, Collection, Self, Mapping, Iterable

import attr
from tqdm import tqdm

from bespin_tools.lib.aws import suppress_boto_error
from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.logging import info

if TYPE_CHECKING:
    # Avoid import loops
    from bespin_tools.lib.aws.ecr import ECRRepository


@attr.define(frozen=True, kw_only=True)
class ECRVulnerabilities:
    critical: tuple[Collection[str], Collection[str]] = attr.field(default=([], []))
    high: tuple[Collection[str], Collection[str]] = attr.field(default=([], []))
    medium: tuple[Collection[str], Collection[str]] = attr.field(default=([], []))
    low: tuple[Collection[str], Collection[str]] = attr.field(default=([], []))

    @classmethod
    def query(cls, repo: ECRRepository) -> Self:
        rv = cls()
        for idx, image in enumerate(repo.images):
            vulns = set(cls._vulns_for_image(repo, image))
            for severity, name in vulns:
                getattr(rv, severity)[1].append(name)
                if idx == 0:
                    getattr(rv, severity)[0].append(name)
        return rv

    def to_report_dict(self) -> Mapping[str, int]:
        rv = dict()
        for sev in self.severities():
            first_image, all_images = getattr(self, sev)
            rv[f"{sev.title()} (Latest version - Total)"] = len(first_image)
            rv[f"{sev.title()} (Latest version - Unique)"] = len(set(first_image))
            rv[f"{sev.title()} (All versions - Total)"] = len(all_images)
            rv[f"{sev.title()} (All versions - Unique)"] = len(set(all_images))
        return rv

    @classmethod
    @cache
    def severities(cls) -> tuple[str, ...]:
        return tuple(sorted(attr.fields_dict(cls).keys()))

    @classmethod
    @suppress_boto_error("ScanNotFoundException")
    def _vulns_for_image(cls, repo: ECRRepository, image: str):
        for finding in paginate(
            repo.client.describe_image_scan_findings,
            repositoryName=repo.name,
            imageId=image,
        ):
            severity = finding["severity"].lower()
            if severity in cls.severities():
                yield severity, finding["title"]


def _get_vulns_worker(repo: ECRRepository, pbars: list[tqdm]) -> ECRRepository | Exception:
    thread_idx = 1 + int(current_thread().name.rsplit("_", 1)[-1])
    pbar = pbars[thread_idx]
    pbar.set_description(f"\tworker {thread_idx} - scanning {repo.name}")
    _ = repo.vulnerabilities  # Prime the cached property at `.vulnerabilities`:
    pbar.set_description(f"\tworker {thread_idx} - idle")
    with pbars[0].get_lock():
        pbars[0].update(1)
        pbars[0].refresh()
    return repo


def cache_repo_vulnerabilities_parallel(
    parallel: int, repos: tuple[ECRRepository, ...]
) -> Iterable[ECRRepository]:
    # Some of the vuln reports are very slow to pull, and some take WAY longer than others. To avoid being head-of-line
    # blocked, parallelize with threads. Parallelism is controllable to avoid AWS rate limits.
    info(f"Scanning {len(repos)} repos in parallel {parallel}...")
    if parallel == 1:
        with tqdm(total=len(repos)) as pbar:
            for repo in repos:
                pbar.set_description(f"Scanning {repo.name}")
                _ = repo.vulnerabilities
                pbar.update(1)
        return

    executor = ThreadPoolExecutor(max_workers=parallel)
    with (
        ExitStack() as stack,
        tqdm(total=len(repos), desc="Repositories scanned") as main_pbar,
    ):
        pbars = [
            main_pbar,
            *(stack.enter_context(tqdm(bar_format="{desc}")) for _ in range(parallel)),
        ]
        for item in as_completed(
            executor.submit(_get_vulns_worker, repo, pbars) for repo in repos
        ):
            yield item.result()
    executor.shutdown()
