from __future__ import annotations

import os
import threading
from functools import cache
from typing import TYPE_CHECKING, Iterable, Mapping

from botocore.exceptions import ClientError

from bespin_tools.lib.cache import dummy_aws_config_file
from bespin_tools.lib.command.environment import EnvironmentVariables
from bespin_tools.lib.errors import BespinctlError
from bespin_tools.lib.util import background_initialized

if TYPE_CHECKING:
    from botocore.client import BaseClient
    from types_boto3_securityhub import SecurityHubClient
    from types_boto3_ec2 import EC2Client
    from types_boto3_sts import STSClient
    from types_boto3_ssm import SSMClient
    from types_boto3_iam import IAMClient
    from types_boto3_acm import ACMClient
    from types_boto3_acm_pca import ACMPCAClient
    from types_boto3_accessanalyzer import AccessAnalyzerClient
    from types_boto3_config import ConfigServiceClient
    from types_boto3_eks import EKSClient
    from types_boto3_identitystore import IdentityStoreClient
    from types_boto3_sso_admin import SSOAdminClient
    from types_boto3_sso import SSOClient
    from types_boto3_sso_oidc import SSOOIDCClient
    from types_boto3_account import AccountClient
    from types_boto3_guardduty import GuardDutyClient
    from types_boto3_cloudfront import CloudFrontClient
    from types_boto3_athena import AthenaClient
    from types_boto3_s3 import S3Client
    from types_boto3_ecr import ECRClient
    from types_boto3_organizations import OrganizationsClient
    from types_boto3_inspector2 import Inspector2Client


DEFAULT_REGION = 'us-east-1'
SSO_START_URL = 'https://d-9067e2261c.awsapps.com/start'
UNNAMED = '<no name>'

def convert_tags_for_display(item: Mapping | Iterable[Mapping]) -> Mapping:
    if isinstance(item, Mapping):
        return item
    rv = dict()
    for pair in item:
        BespinctlError.invariant(set(pair.keys()) == {'Key', 'Value'}, f"Input doesn't look like an AWS API tag array: {item}")
        rv[pair['Key']] = pair['Value']
    rv.setdefault('Name', UNNAMED)
    return rv

def paginate(func: callable,  **kwargs):
    BespinctlError.invariant(callable(func), f"Expected a bound method, got {type(func)} {func}")
    from botocore.client import BaseClient

    client = func.__self__
    BespinctlError.invariant(isinstance(client, BaseClient), f"Expected a boto3 client method, but got a method bound to {client}: {func}")
    # Cute trick from https://www.reddit.com/r/aws/comments/7p5rhl/comment/dsfvb0f/:
    paginator = client.get_paginator(func.__name__)
    for page in paginator.paginate(**kwargs).result_key_iters():
        for result in page:
            yield result

def is_account_id(candidate: str) -> bool:
    # Silly regex, trix are for kids!
    return len(candidate) == 12 and all(c.isdigit() for c in candidate)

def assert_account_id(candidate) -> str:
    BespinctlError.invariant(
        isinstance(candidate, str) and is_account_id(candidate),
        f"Expected a string account ID, got {type(candidate)} '{candidate}'"
    )
    return candidate

def is_throttling_error(e: ClientError) -> bool:
    """
    Determine if a boto3 ClientError is due to throttling / rate limiting
    """
    throttling_error_codes = (
        'ProvisionedThroughputExceededException',
        'RequestLimitExceeded',
        'Throttling',
        'ThrottlingException',
    )

    if hasattr(e, 'response'):
        return e.response.get('Error', {}).get('Code', '') in throttling_error_codes
    return False

@cache
def _mutate_environment_to_isolate_bespinctl() -> bool:
    """
    Mutates the environment and AWS-related config files to "hermetically" isolate bespinctl from other configs on
    the invoking system related to AWSCLI and credentials. The goal is to make bespinctl's environment be as consistent
    and reproducible across environments (workstations, CICD, etc.) as possible.

    This mutation can be disabled if the DOS_CLOUD_CITY_BESPINCTL_MUTATE_ENV is set to 0. That capability shouldn't be
    widely used, but it can be useful when debugging behavior differences between bespinctl and AWSCLI, or in CICD.
    """
    BespinctlError.invariant(
        threading.current_thread() == threading.main_thread(),
        f"Method can only be called from the main thread, not {threading.current_thread()}",
    )
    if rv := os.environ.get('DOS_CLOUD_CITY_BESPINCTL_MUTATE_ENV', '1').lower() in ('true', '1'):
        client_init_args = {'region_name': DEFAULT_REGION}
        # Even when overriden with a boto3.Cofig object, boto3 clients sometimes attempt to "merge" data in from ~/.aws.config.
        # At present, that's more trouble than it's worth: one of the goals of bespinctl is to work without AWSCLI entirely,
        # and some values in ~/.aws.config can cause bespinctl commands to fail. At some point, we'll probably be a little more
        # granular in how/when we clobber the config file, but for now it's easiest to simply not honor it anywhere at all
        # within bespinctl.
        # Ref: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/configuration.html
        dummy_config = str(dummy_aws_config_file())
        client_init_args['profile_name'] = 'bespinctl'
        global_env = EnvironmentVariables("isolation from awscli")
        for k in sorted(os.environ.keys()):
            if k.startswith(('AWS_', 'BOTO_', 'TF_', 'TG_', 'TERRAGRUNT', 'TERRAFORM')):
                del global_env[k]
            global_env['AWS_CONFIG_FILE'] = global_env['BOTO_CONFIG'] = global_env['AWS_SHARED_CREDENTIALS_FILE'] = dummy_config
            global_env['AWS_PROFILE'] = global_env['AWS_DEFAULT_PROFILE'] = 'bespinctl'
            os.environ.update(global_env)
    return rv



class ClientGetter:
    """
    Mixin class used for getting typed boto3 clients. If a new client type is needed in surrounding code, add it to
    this file by updating the imports at the top to pull in its types, and adding a '$new_service_client()` method
    to this class.
    """
    @staticmethod
    @cache
    @background_initialized
    def __background_create_client(kind: str, **session_kwargs):
        """
        In a background thread, import boto and construct a session and client.
        This is backgrounded because it is IO intensive (loads lots of JSON specs to create Python objects) and thus
        parallelizable even with the GIL. Given how frequently the action of getting a boto client is needed inside
        bespinctl, up to several seconds of startup time are saved by backgrounding and parallelizing certain client
        fetches.
        """
        import boto3
        from botocore.config import Config

        session = boto3.Session(**session_kwargs)
        client_kwargs = {
            'config': Config(
                region_name=DEFAULT_REGION,
                retries={
                    'max_attempts': 0,
                    'mode': 'standard',
                }
            ),
        }
        return session.client(kind, **client_kwargs)


    def _get_client(self, kind: str, **session_kwargs):
        session_kwargs.setdefault('region_name', DEFAULT_REGION)
        if _mutate_environment_to_isolate_bespinctl():
            existing_profile_name = session_kwargs.get('profile_name', 'bespinctl')
            BespinctlError.invariant(
                existing_profile_name == 'bespinctl',
                f"Session requested invalid profile name: {existing_profile_name} != bespinctl",
            )
            session_kwargs['profile_name'] = 'bespinctl'
        return self.__background_create_client(kind, **session_kwargs)

    def security_hub_client(self, **kwargs) -> SecurityHubClient:
        return self._get_client('securityhub', **kwargs)

    def ec2_client(self, **kwargs) -> EC2Client:
        return self._get_client('ec2', **kwargs)

    def ecr_client(self, **kwargs) -> ECRClient:
        return self._get_client('ecr', **kwargs)

    def sts_client(self, **kwargs) -> STSClient:
        return self._get_client('sts', **kwargs)

    def ssm_client(self, **kwargs) -> SSMClient:
        return self._get_client('ssm', **kwargs)

    def iam_client(self, **kwargs) -> IAMClient:
        return self._get_client('iam', **kwargs)

    def access_analyzer_client(self, **kwargs) -> AccessAnalyzerClient:
        return self._get_client('accessanalyzer', **kwargs)

    def config_client(self, **kwargs) -> ConfigServiceClient:
        return self._get_client('config', **kwargs)

    def eks_client(self, **kwargs) -> EKSClient:
        return self._get_client('eks', **kwargs)

    def identity_store_client(self, **kwargs) -> IdentityStoreClient:
        return self._get_client('identitystore', **kwargs)

    def account_client(self, **kwargs) -> AccountClient:
        return self._get_client('account', **kwargs)

    def sso_client(self, **kwargs) -> SSOClient:
        return self._get_client('sso', **kwargs)

    def acm_client(self, **kwargs) -> ACMClient:
        return self._get_client('acm', **kwargs)

    def acm_pca_client(self, **kwargs) -> ACMPCAClient:
        return self._get_client('acm-pca', **kwargs)

    def sso_oidc_client(self, **kwargs) -> SSOOIDCClient:
        return self._get_client('sso-oidc', **kwargs)

    def sso_admin_client(self, **kwargs) -> SSOAdminClient:
        return self._get_client('sso-admin', **kwargs)

    def guard_duty_client(self, **kwargs) -> GuardDutyClient:
        return self._get_client('guardduty', **kwargs)

    def cloudfront_client(self, **kwargs) -> CloudFrontClient:
        return self._get_client('cloudfront', **kwargs)

    def inspector2_client(self, **kwargs) -> Inspector2Client:
        return self._get_client('inspector2', **kwargs)

    def athena_client(self, **kwargs) -> AthenaClient:
        return self._get_client('athena', **kwargs)

    def s3_client(self, **kwargs) -> S3Client:
        return self._get_client('s3', **kwargs)

    def organizations_client(self, **kwargs) -> OrganizationsClient:
        return self._get_client('organizations', **kwargs)
