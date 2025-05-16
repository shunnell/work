from types_boto3_accessanalyzer import AccessAnalyzerClient
from types_boto3_iam import IAMClient
from types_boto3_iam.type_defs import RoleTypeDef
from bespin_tools.lib.testing.iam_validation import validate_inline_policy
# Use PyTest fixtures
# If this returns a vector runs parmaterized
def test_validate_sandbox_dev_inline_policy(infra_iam_client: IAMClient, infra_access_analyzer_client: AccessAnalyzerClient, devsecops_infra_role: RoleTypeDef):
    validate_inline_policy(
        infra_access_analyzer_client,
        infra_iam_client,
        devsecops_infra_role,
        exclude_issue_codes=('CREATE_SLR_WITH_STAR_IN_RESOURCE',),
        exclude_finding_types=('SUGGESTION',))
