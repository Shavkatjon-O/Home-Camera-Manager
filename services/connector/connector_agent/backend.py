"""Client of the backend's connector endpoints, which the connector always calls outbound."""

import httpx

__all__ = ["DEVICE_GRANT", "BackendClient", "BackendError", "GrantPending", "Revoked"]

DEVICE_GRANT = "urn:ietf:params:oauth:grant-type:device_code"
TIMEOUT_SECONDS = 20.0


class BackendError(Exception):
    """The backend could not be reached or refused a call."""


class Revoked(BackendError):
    """The backend no longer accepts the connector's token."""


class GrantPending(Exception):
    """The token endpoint answered with an RFC 8628 error.

    Attributes:
        error: Error code, such as authorization_pending.
        interval: New poll interval sent with slow_down.
    """

    def __init__(self, error: str, interval: int | None = None):
        """Create the error.

        Args:
            error: Error code.
            interval: New poll interval, if sent.
        """
        super().__init__(error)
        self.error = error
        self.interval = interval


class BackendClient:
    """Calls the backend under /api/v1/connector.

    Attributes:
        base_url: Base address of the backend.
        token: Connector token, once paired.
        verify: Whether to verify TLS certificates.
        transport: HTTP transport, replaced in tests.
    """

    def __init__(
        self,
        base_url: str,
        token: str | None = None,
        verify: bool = True,
        transport: httpx.AsyncBaseTransport | None = None,
    ):
        """Bind the client to a backend.

        Args:
            base_url: Base address of the backend.
            token: Connector token, if paired.
            verify: Whether to verify TLS certificates.
            transport: HTTP transport, the default when omitted.
        """
        self.base_url = base_url.rstrip("/")
        self.token = token
        self.verify = verify
        self.transport = transport

    async def call(self, method: str, path: str, body: dict | None = None) -> httpx.Response:
        """Send one request.

        Args:
            method: HTTP method.
            path: Path under /api/v1/connector.
            body: JSON body, if any.

        Returns:
            The response, whatever its status.

        Raises:
            BackendError: The backend cannot be reached.
        """
        headers = {"Authorization": f"Bearer {self.token}"} if self.token else {}
        try:
            async with httpx.AsyncClient(
                base_url=self.base_url, timeout=TIMEOUT_SECONDS, verify=self.verify, transport=self.transport
            ) as http:
                return await http.request(method, f"/api/v1/connector{path}", json=body, headers=headers)
        except httpx.HTTPError as exc:
            raise BackendError(f"The backend does not answer ({type(exc).__name__})")

    async def json(self, method: str, path: str, body: dict | None = None) -> dict:
        """Send a request that must succeed and read its JSON.

        Args:
            method: HTTP method.
            path: Path under /api/v1/connector.
            body: JSON body, if any.

        Returns:
            The JSON answer, empty for an empty one.

        Raises:
            Revoked: The backend refused the token.
            BackendError: The backend refused the call otherwise.
        """
        response = await self.call(method, path, body)
        if response.status_code == 401:
            raise Revoked("The backend no longer accepts this connector")
        if not response.is_success:
            raise BackendError(f"The backend answered HTTP {response.status_code} to {path}")
        return response.json() if response.content else {}

    async def device_code(self, name: str, version: str, public_key: str | None = None) -> dict:
        """Open a pairing.

        Args:
            name: Name the connector suggests.
            version: Agent version.
            public_key: WireGuard public key, for the tunnel.

        Returns:
            The RFC 8628 device authorization.
        """
        return await self.json("POST", "/device-code", {"name": name, "version": version, "public_key": public_key})

    async def token_for(self, device_code: str) -> dict:
        """Poll the token endpoint once.

        Args:
            device_code: The device code.

        Returns:
            The connector's credentials.

        Raises:
            GrantPending: The pairing is not claimed yet, is polled too fast, expired or was refused.
            BackendError: The backend refused the call otherwise.
        """
        response = await self.call("POST", "/token", {"grant_type": DEVICE_GRANT, "device_code": device_code})
        if response.status_code == 400:
            try:
                body = response.json()
            except ValueError:
                body = {}
            raise GrantPending(str(body.get("error") or "invalid_grant"), body.get("interval"))
        if not response.is_success:
            raise BackendError(f"The backend answered HTTP {response.status_code} to the token poll")
        return response.json()

    async def heartbeat(self, report: dict) -> dict:
        """Send a heartbeat.

        Args:
            report: The heartbeat.

        Returns:
            The backend's acknowledgement.
        """
        return await self.json("POST", "/heartbeat", report)

    async def report_discovery(self, cameras: list[dict]) -> None:
        """Report the cameras a discovery run found.

        Args:
            cameras: The candidates.
        """
        await self.json("POST", "/discovery", {"cameras": cameras})

    async def config(self) -> dict:
        """Read the connector's camera list.

        Returns:
            The list with its digest.
        """
        return await self.json("GET", "/config")
