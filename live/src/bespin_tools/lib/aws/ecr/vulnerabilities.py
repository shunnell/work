from __future__ import annotations

from concurrent.futures import ThreadPoolExecutor, as_completed
from functools import cache
from random import shuffle
from typing import Mapping, TYPE_CHECKING, Iterable

import attr
from more_itertools import chunked
from tqdm import tqdm

from bespin_tools.lib.aws.util import paginate
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.logging import info

if TYPE_CHECKING:
    from bespin_tools.lib.aws.ecr import ECRRepository


@attr.define(frozen=True, kw_only=True)
class ECRVulnerabilities:
    critical: list[str] = attr.field(factory=list)
    high: list[str] = attr.field(factory=list)
    medium: list[str] = attr.field(factory=list)
    low: list[str] = attr.field(factory=list)

    def update(self, repo_name: str, severity: str, vuln: str):
        severity = severity.lower()
        BespinctlError.invariant(
            severity in self.severities(),
            f"{repo_name}: Severity '{severity}' not found for vuln: {vuln}",
        )
        getattr(self, severity).append(vuln)

    def to_report_dict(self) -> Mapping[str, int]:
        rv = dict()
        for sev in self.severities():
            vulns = getattr(self, sev)
            rv[f"{sev.title()} - Total"] = len(vulns)
            rv[f"{sev.title()} - Unique"] = len(set(vulns))
        return rv

    @classmethod
    @cache
    def severities(cls) -> tuple[str, ...]:
        fields = set(attr.fields_dict(cls).keys())
        expected = {'critical', 'high', 'medium', 'low'}
        BespinctlError.invariant(expected.intersection(fields) == expected, f"Missing severities: {fields}")
        return tuple(sorted(expected))

def _cache_vulnerabilities(repos: list[ECRRepository], client):
    by_name = {r.name: r for r in repos}
    filter_criteria = {
        'ecrImageRepositoryName': [dict(comparison='EQUALS', value=repo.name) for repo in repos],
        'severity': [dict(comparison='EQUALS', value=s.upper()) for s in ECRVulnerabilities.severities()],
        'findingStatus': [dict(comparison='NOT_EQUALS', value='CLOSED')],
    }
    for finding in paginate(client.list_findings,filterCriteria=filter_criteria):
        resources, = finding['resources']
        repo = by_name[resources['details']['awsEcrContainerImage']['repositoryName']]
        repo.vulnerabilities.update(repo.name, finding['severity'], finding['title'])
    return repos

def cache_repo_vulnerabilities_parallel(
    parallel: int,
    repos: Iterable[ECRRepository],
    timeout=600,  # NOTE: Timeout may need to be bumped as we get more repos
) -> Iterable[ECRRepository]:
    # Some of the vuln reports are very slow to pull, and some take WAY longer than others. To avoid being head-of-line
    # blocked, parallelize with threads. Parallelism is controllable to avoid AWS rate limits.
    repos = list(repos)
    info(f"Scanning {len(repos)} repos in parallel {parallel}...")
    # Shuffle to avoid clogging the worker with all one tenant's big, slow-to-scan repos:
    shuffle(repos)
    with tqdm(total=len(repos), desc="Repositories scanned") as pbar, ThreadPoolExecutor(max_workers=parallel) as executor:
        futures = []
        for chunk in chunked(repos, 10):  # 10 is the max allowed batch size by inspector
            futures.append(executor.submit(_cache_vulnerabilities, chunk, chunk[0].account.inspector2_client()))
        for item in as_completed(futures, timeout=timeout):
            for repo in item.result():
                yield repo
                pbar.update(1)
