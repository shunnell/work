from __future__ import annotations

from base64 import urlsafe_b64encode
from datetime import timedelta, datetime, UTC

from bespin_tools.lib.aws.account import Account
from bespin_tools.lib.cache import cache_result
from bespin_tools.lib.errors import BespinctlError

K8S_AWS_ID_HEADER = 'x-k8s-aws-id'
K8S_TOKEN_CACHE_TTL = timedelta(minutes=14)


def _get_token(account: Account, cluster: str, token_ttl_seconds: int):
    """Generate a presigned url token to pass to kubectl.
    This code was cribbed from
    https://github.com/aws/aws-cli/blob/66f9e380841a79628d62c1d6f9e1501207d74e9a/awscli/customizations/eks/get_token.py

    That code is licensed under Apache 2.0 and thus should be reusable/reinterpretable here. This function should
    be considered a derivation/implementation of that code for licensing purposes.

    Additionally, the PoC for this code was inspired by this unlicensed, non-AWS example:
    https://github.com/peak-ai/eks-token/blob/4cd54b1aff6d41679fcd894cd61ae6f4f0cf82cf/eks_token/logics.py#L12

    Importing and using that entire package (which is the 'awscli' CLI layer on top of boto3) was not done and has
    two drawbacks:
    - The 'awscli' dependency is very heavy and costly (in time, memory, artifact size) to imporrt and use.
    - Having 'awscli' installed via Python as well as on the system itself causes conflicts wherein the system awscli
      (which is also Python) internally imports from the bespinctl-installed awscli library, causing incompatibilities
      between system-awscli and bespinctl-awscli components, leading to crashes and awscli errors for users.
    """
    BespinctlError.invariant(token_ttl_seconds > 0, f"TTL must be positive: {token_ttl_seconds}")
    BespinctlError.invariant(len(cluster) >= len(cluster.strip()) > 0, f"Cluster name invalid: '{cluster}'")
    sts = account.sts_client()
    sts.meta.events.register('provide-client-params.sts.GetCallerIdentity', _sts_retrieve_k8s_aws_id)
    sts.meta.events.register('before-sign.sts.GetCallerIdentity', _sts_inject_k8s_aws_id_header)

    caller_identity_with_headers = sts.generate_presigned_url(
        sts.get_caller_identity.__name__,
        Params={K8S_AWS_ID_HEADER: cluster},
        ExpiresIn=token_ttl_seconds,
        HttpMethod='GET',
    )

    token = urlsafe_b64encode(caller_identity_with_headers.encode('utf-8')).decode('utf-8').rstrip('=')
    return f'k8s-aws-v1.{token}'


def _sts_retrieve_k8s_aws_id(params, context, **kwargs):
    if K8S_AWS_ID_HEADER in params:
        context[K8S_AWS_ID_HEADER] = params.pop(K8S_AWS_ID_HEADER)

def _sts_inject_k8s_aws_id_header(request, **kwargs):
    if K8S_AWS_ID_HEADER in request.context:
        request.headers[K8S_AWS_ID_HEADER] = request.context[K8S_AWS_ID_HEADER]

@cache_result(ttl=K8S_TOKEN_CACHE_TTL)
def get_token_for_cluster(account: Account, cluster: str):
    return {
        "kind": "ExecCredential",
        "apiVersion": "client.authentication.k8s.io/v1beta1",
        "spec": {},
        "status": {
            "expirationTimestamp": (datetime.now(UTC) + K8S_TOKEN_CACHE_TTL).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "token":  _get_token(account, cluster, int(K8S_TOKEN_CACHE_TTL.total_seconds())),
        },
    }
