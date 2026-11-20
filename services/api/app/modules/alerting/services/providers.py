"""Push providers: FCM HTTP v1 when a Firebase project is set up, and ntfy as the path without Google."""

import json
import logging
import time
from dataclasses import dataclass
from pathlib import Path

import httpx
import jwt

from app.core.config import settings
from app.modules.alerting.enums import PushProvider

__all__ = [
    "Delivery",
    "FcmProvider",
    "NtfyProvider",
    "Provider",
    "providers",
]

logger = logging.getLogger(__name__)

FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
FCM_URL = "https://fcm.googleapis.com/v1/projects/{project}/messages:send"
TOKEN_LIFETIME_SECONDS = 3600
TOKEN_MARGIN_SECONDS = 120
TIMEOUT_SECONDS = 10.0
GONE_STATUSES = (404, 410)


@dataclass(frozen=True)
class Delivery:
    """Outcome of one push.

    Attributes:
        ok: Whether the provider accepted it.
        gone: Whether the target no longer exists and should be dropped.
        error: Reason of a failure.
    """

    ok: bool
    gone: bool = False
    error: str | None = None


class Provider:
    """A push service.

    Attributes:
        name: Provider value.
        transport: HTTP transport, replaced in tests.
    """

    name: PushProvider

    def __init__(self, transport: httpx.AsyncBaseTransport | None = None):
        """Create the provider.

        Args:
            transport: HTTP transport, the default when omitted.
        """
        self.transport = transport

    @property
    def enabled(self) -> bool:
        """bool: Whether the provider is set up."""
        return False

    def accepts(self, token: str) -> bool:
        """Tell whether a target token is valid for this provider.

        Args:
            token: The token.

        Returns:
            True when it can be delivered to.
        """
        return bool(token)

    async def send(self, token: str, data: dict[str, str]) -> Delivery:
        """Deliver a data message to a target.

        Args:
            token: The target's token.
            data: Message data, ids only.

        Returns:
            The outcome.
        """
        raise NotImplementedError


class FcmProvider(Provider):
    """Firebase Cloud Messaging HTTP v1 with a service account's short-lived OAuth2 token.

    Attributes:
        name: fcm.
        project: Firebase project id.
        key_file: Path of the service account key file.
        access_token: Cached OAuth2 token.
        expires: Epoch seconds the cached token expires at.
    """

    name = PushProvider.FCM

    def __init__(self, project: str, key_file: str, transport: httpx.AsyncBaseTransport | None = None):
        """Create the provider.

        Args:
            project: Firebase project id; empty turns the provider off.
            key_file: Path of the service account key file.
            transport: HTTP transport, the default when omitted.
        """
        super().__init__(transport)
        self.project = project
        self.key_file = key_file
        self.access_token: str | None = None
        self.expires = 0.0

    @property
    def enabled(self) -> bool:
        """bool: Whether a project and a readable key file are set up."""
        return bool(self.project and self.key_file and Path(self.key_file).is_file())

    def assertion(self, account: dict, now: float) -> str:
        """Sign the JWT a service account exchanges for an access token.

        Args:
            account: The service account key.
            now: Current epoch seconds.

        Returns:
            The RS256 assertion.
        """
        claims = {
            "iss": account["client_email"],
            "scope": FCM_SCOPE,
            "aud": account.get("token_uri", "https://oauth2.googleapis.com/token"),
            "iat": int(now),
            "exp": int(now) + TOKEN_LIFETIME_SECONDS,
        }
        return jwt.encode(claims, account["private_key"], algorithm="RS256")

    async def token(self, http: httpx.AsyncClient) -> str:
        """Return a valid OAuth2 token, fetching a new one shortly before the cached one expires.

        Args:
            http: HTTP client.

        Returns:
            The token.

        Raises:
            httpx.HTTPError: Google refused or could not be reached.
        """
        now = time.time()
        if self.access_token and now < self.expires - TOKEN_MARGIN_SECONDS:
            return self.access_token
        account = json.loads(Path(self.key_file).read_text())
        response = await http.post(
            account.get("token_uri", "https://oauth2.googleapis.com/token"),
            data={
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": self.assertion(account, now),
            },
        )
        response.raise_for_status()
        body = response.json()
        self.access_token = body["access_token"]
        self.expires = now + float(body.get("expires_in", TOKEN_LIFETIME_SECONDS))
        return self.access_token

    async def send(self, token: str, data: dict[str, str]) -> Delivery:
        """Send a high-priority data message, which the app renders itself.

        Args:
            token: FCM registration token.
            data: Message data, ids only.

        Returns:
            The outcome; an unregistered token is gone.
        """
        message = {"message": {"token": token, "data": data, "android": {"priority": "high"}}}
        try:
            async with httpx.AsyncClient(timeout=TIMEOUT_SECONDS, transport=self.transport) as http:
                access = await self.token(http)
                response = await http.post(
                    FCM_URL.format(project=self.project), json=message, headers={"Authorization": f"Bearer {access}"}
                )
        except (httpx.HTTPError, KeyError, ValueError) as exc:
            return Delivery(ok=False, error=f"FCM could not be reached ({type(exc).__name__})")
        if response.is_success:
            return Delivery(ok=True)
        gone = response.status_code in GONE_STATUSES or "UNREGISTERED" in response.text
        return Delivery(ok=False, gone=gone, error=f"FCM answered HTTP {response.status_code}")


class NtfyProvider(Provider):
    """An ntfy server: the app subscribes to a topic of its own and the backend publishes to it.

    Attributes:
        name: ntfy.
        base_url: Base address of the ntfy server; topics outside it are refused.
        access_token: Token for a protected server, if any.
    """

    name = PushProvider.NTFY

    def __init__(self, base_url: str, access_token: str = "", transport: httpx.AsyncBaseTransport | None = None):
        """Create the provider.

        Args:
            base_url: Base address of the ntfy server; empty turns the provider off.
            access_token: Token for a protected server.
            transport: HTTP transport, the default when omitted.
        """
        super().__init__(transport)
        self.base_url = base_url.rstrip("/")
        self.access_token = access_token

    @property
    def enabled(self) -> bool:
        """bool: Whether an ntfy server is set up."""
        return bool(self.base_url)

    def accepts(self, token: str) -> bool:
        """Accept only topic addresses on the configured server, so the backend posts nowhere else.

        Args:
            token: The topic address.

        Returns:
            True for an address of a topic under the base address.
        """
        if not self.enabled or not token.startswith(f"{self.base_url}/"):
            return False
        topic = token[len(self.base_url) + 1 :]
        return bool(topic) and "/" not in topic and len(topic) >= 16

    async def send(self, token: str, data: dict[str, str]) -> Delivery:
        """Publish the message data as JSON to the topic.

        Args:
            token: The topic address.
            data: Message data, ids only.

        Returns:
            The outcome.
        """
        headers = {"Title": "Smart Surveillance", "Priority": "high", "Tags": "rotating_light"}
        if self.access_token:
            headers["Authorization"] = f"Bearer {self.access_token}"
        try:
            async with httpx.AsyncClient(timeout=TIMEOUT_SECONDS, transport=self.transport) as http:
                response = await http.post(token, content=json.dumps(data).encode(), headers=headers)
        except httpx.HTTPError as exc:
            return Delivery(ok=False, error=f"ntfy could not be reached ({type(exc).__name__})")
        if response.is_success:
            return Delivery(ok=True)
        return Delivery(
            ok=False, gone=response.status_code in GONE_STATUSES, error=f"ntfy answered HTTP {response.status_code}"
        )


def providers() -> dict[PushProvider, Provider]:
    """Build the providers from the settings.

    Returns:
        Every provider by name, enabled or not.
    """
    return {
        PushProvider.FCM: FcmProvider(settings.fcm_project_id, settings.fcm_service_account_file),
        PushProvider.NTFY: NtfyProvider(settings.ntfy_url, settings.ntfy_token),
    }
