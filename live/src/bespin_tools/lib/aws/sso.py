from __future__ import annotations

import webbrowser
from time import sleep, monotonic
from typing import TYPE_CHECKING

from bespin_tools.lib.aws.util import SSO_START_URL
from bespin_tools.lib.logging import attention

if TYPE_CHECKING:
    from types_boto3_sso_oidc import SSOOIDCClient


def sleep_until(time: float) -> float:
    now = monotonic()
    if now > time:
        return now
    sleep(max((0, time - now)))
    return monotonic()

def new_sso_token(sso_oidc_client: SSOOIDCClient):
    client_creds = sso_oidc_client.register_client(
        clientName='bespinctl',
        clientType='public',
    )
    device_authorization = sso_oidc_client.start_device_authorization(
        clientId=client_creds['clientId'],
        clientSecret=client_creds['clientSecret'],
        startUrl=SSO_START_URL,
    )
    t0 = monotonic()
    expires_in = device_authorization['expiresIn']
    interval = device_authorization['interval']
    url = device_authorization['verificationUriComplete']
    attention(f"Authorizing for token creation via {url}")
    attention(f"Authorization code in browser should be {url.rsplit('=', 1)[-1]}")
    webbrowser.open(url, autoraise=True)
    for _ in range(max((expires_in // interval, 1))):
        try:
            return sso_oidc_client.create_token(
                grantType='urn:ietf:params:oauth:grant-type:device_code',
                deviceCode=device_authorization['deviceCode'],
                clientId=client_creds['clientId'],
                clientSecret=client_creds['clientSecret'],
            )['accessToken']
        except sso_oidc_client.exceptions.AuthorizationPendingException:
            # You're not allowed to poll any more frequently than 'interval'. This is a kind of public/auth-free AWS
            # endpoint, so they use more explicit/ordinary rate limiting than they do for internal APIs' rate limits.
            t0 = sleep_until(t0 + interval)
    raise ValueError(f'Could not get credentials within the device auth window {expires_in}, {interval}')


