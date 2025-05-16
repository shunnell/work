# Import all common fixtures
from bespin_tools.lib.testing.conftest import *
import pytest

@pytest.fixture(scope="session")
def dev_infra_role(infra_iam_client: IAMClient) -> RoleTypeDef:
    return locate_role(infra_iam_client, "/aws-reserved/sso.amazonaws.com/", "AWSReservedSSO_OCAM_Dev_Infra.*")

@pytest.fixture(scope="session")
def devsecops_infra_role(infra_iam_client: IAMClient) -> RoleTypeDef:
    return locate_role(infra_iam_client, "/aws-reserved/sso.amazonaws.com/", "AWSReservedSSO_OCAM_DevSecOps_Infra.*")