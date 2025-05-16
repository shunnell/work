from __future__ import annotations

import pytest
from types_boto3_accessanalyzer import AccessAnalyzerClient
from types_boto3_iam import IAMClient
from types_boto3_iam.type_defs import RoleTypeDef

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.aws.organization import Organization
from bespin_tools.lib.testing.iam_simulation import locate_role

@pytest.fixture(scope="session", params=["Platform-Infra"])
def infra_account(request) -> Account:
    """
    Get Accounts
    """
    x, = Organization.get_accounts(request.param)
    return x

@pytest.fixture(scope="session")
def infra_iam_client(infra_account: Account) -> IAMClient:
    return infra_account.iam_client()

@pytest.fixture(scope="session")
def infra_access_analyzer_client(infra_account: Account) -> AccessAnalyzerClient:
    return infra_account.access_analyzer_client()

@pytest.fixture(scope="session", params=["Data-Platform", "OPR", "IVA"])
def sandbox_account(request) -> Account:
    """
    Get Accounts
    """
    x, = Organization.get_accounts(request.param)
    return x

@pytest.fixture(scope="session")
def sandbox_iam_client(sandbox_account: Account) -> IAMClient:
    return sandbox_account.iam_client()

@pytest.fixture(scope="session")
def sandbox_access_analyzer_client(sandbox_account: Account) -> AccessAnalyzerClient:
    return sandbox_account.access_analyzer_client()

@pytest.fixture(scope="session")
def sandbox_dev_role(sandbox_iam_client: IAMClient) -> RoleTypeDef:
    return locate_role(sandbox_iam_client, "/aws-reserved/sso.amazonaws.com/", "AWSReservedSSO_Sandbox_Dev.*")