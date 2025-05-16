from __future__ import annotations

from functools import cache
from itertools import chain
import json
from pprint import pformat
from typing import Iterable, Literal, NamedTuple
import re
from types_boto3_iam import IAMClient
from types_boto3_iam.type_defs import RoleTypeDef, PolicyDocumentTypeDef

from bespin_tools.lib.aws.util import paginate, is_throttling_error

from retrying import retry


class ContextEntry(NamedTuple):
    ContextKeyName: str
    ContextKeyType: str
    ContextKeyValues: list[str]

type EvalDecision = Literal['allowed'] | Literal['implicitDeny'] | Literal['deny']

def locate_role(client: IAMClient, path: str, pattern: str) -> RoleTypeDef:
    """
    Locate the 'Sandbox_Dev' role in the current account using a regex search of roles
    """
    compiled_pattern = re.compile(pattern)
    for role in paginate(client.list_roles, PathPrefix=path):
        if compiled_pattern.match(role['RoleName']):
            return role
    raise ValueError(f"Role {pattern} not found")

@retry(stop_max_attempt_number=5,wait_exponential_multiplier=1000, wait_exponential_max=10000, retry_on_exception=is_throttling_error) # type: ignore
def simulate_identity_policy(client: IAMClient, iam_role: RoleTypeDef, action_expectations: dict[str, EvalDecision], resources: list[str], context_entries: list[ContextEntry] = []):
    """
    Use `IAMClient.simulate_custom_policy` to simulate all of the Identity based policies attached to the specified role
    NOTE: DOES NOT simulate service control policies or resource policies
    Service Control Policy support in the simulator is essentially broken: https://github.com/aws/aws-sdk/issues/102
    Resource Policies could be added to this simulation logic later, by looking up the current policy on the resource(s)
    but that requires using real resources instead of mocks.
    """
    actions = list(action_expectations.keys())
    
    policy_input_list = _get_policy_input_list(client, iam_role['RoleName'])

    response = client.simulate_custom_policy(
        PolicyInputList=policy_input_list,
        ActionNames=actions,
        ResourceArns=resources
    )
    assert 'EvaluationResults' in response
    assert len(response['EvaluationResults']) > 0
    for result in response['EvaluationResults']:
        assert 'EvalDecision' in result
        actual = result['EvalDecision']
        expected = action_expectations[result["EvalActionName"]]
        explanation_text = f"The actual EvalDecision '{actual}' did not match expected decision '{expected}'\n{pformat(result)}"
        assert actual == expected, explanation_text

def _get_policy_document(client: IAMClient, policy_arn: str) -> PolicyDocumentTypeDef:
    response = client.get_policy(PolicyArn=policy_arn)
    version_id = response['Policy'].get('DefaultVersionId')
    assert version_id
    response = client.get_policy_version(
        PolicyArn=policy_arn,
        VersionId=version_id
    )
    document = response['PolicyVersion'].get('Document')
    assert document
    return document

def _get_attached_policy_documents(client: IAMClient, iam_role_name: str) -> Iterable[PolicyDocumentTypeDef]:
    inline_policies = client.list_role_policies(
        RoleName=iam_role_name
    )['PolicyNames']
    for inline_policy_name in inline_policies:
        yield client.get_role_policy(
                PolicyName=inline_policy_name,
                RoleName=iam_role_name
            )['PolicyDocument'] 

def _get_inline_policy_documents(client: IAMClient, iam_role_name: str) -> Iterable[PolicyDocumentTypeDef]:
    attached_policies = client.list_attached_role_policies(
        RoleName=iam_role_name
    )['AttachedPolicies']
    for policy_ref in attached_policies:
        policy_arn = policy_ref.get('PolicyArn')
        assert policy_arn
        yield _get_policy_document(client, policy_arn) 

def _get_policy_documents(client: IAMClient, iam_role_name: str) -> Iterable[PolicyDocumentTypeDef]:
    return chain(_get_attached_policy_documents(client, iam_role_name), _get_inline_policy_documents(client, iam_role_name))

@cache
def _get_policy_input_list(client: IAMClient, iam_role_name: str) -> list[str]:
    policy_documents = _get_policy_documents(client, iam_role_name)
    return [json.dumps(document) for document in policy_documents]