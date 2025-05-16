from __future__ import annotations

from typing import Iterable, Literal
from types_boto3_accessanalyzer import AccessAnalyzerClient
from types_boto3_iam import IAMClient
from types_boto3_iam.type_defs import RoleTypeDef
import json

type FindingType = Literal['ERROR'] | Literal['SECURITY_WARNING'] | Literal['SUGGESTION'] | Literal['WARNING']

def validate_inline_policy(
        access_analyzer_client: AccessAnalyzerClient,
        iam_client: IAMClient, role: RoleTypeDef,
        role_policy_name: str = 'AwsSSOInlinePolicy',
        exclude_finding_types: Iterable[FindingType] =[],
        exclude_issue_codes: Iterable[str] =[]):
    response = iam_client.get_role_policy(RoleName=role['RoleName'], PolicyName=role_policy_name)
    policy_document_parsed = response['PolicyDocument']
    policy_document_str = json.dumps(policy_document_parsed)
    response = access_analyzer_client.validate_policy(policyDocument=policy_document_str, policyType='IDENTITY_POLICY')
    findings = response.get('findings', [])
    if findings == []:
        # Don't bother filtering findings if nothing to report
        return
    findings = [
        finding for finding in findings
        if finding['findingType'] not in exclude_finding_types and finding['issueCode'] not in exclude_issue_codes
    ]
    assert not findings, f"Policy validation failed with finding:\n{json.dumps(findings, indent=4)}"