"""Client for the HTTP API of a V380 camera bridge."""

import httpx

API_PORT = 8080
TIMEOUT_SECONDS = 5.0

LIGHT_MODES = ("on", "off", "auto")


class BridgeError(Exception):
    """Error raised when a bridge cannot be reached or refuses a command."""

    pass


class BridgeClient:
    """Client for the light and siren commands of one bridge.

    Attributes:
        base_url: Base URL of the bridge API.
        timeout: Request timeout in seconds.
    """

    def __init__(self, host: str, port: int = API_PORT, timeout: float = TIMEOUT_SECONDS):
        """Bind the client to a bridge.

        Args:
            host: Bridge host.
            port: Bridge API port.
            timeout: Request timeout in seconds.
        """
        self.base_url = f"http://{host}:{port}"
        self.timeout = timeout

    async def available(self) -> bool:
        """Check whether the bridge reports that it is running.

        Returns:
            True when the status endpoint answers with the running status, False on any failure.
        """
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as http:
                response = await http.get(f"{self.base_url}/api/status")
        except httpx.HTTPError:
            return False
        if response.status_code != 200:
            return False
        try:
            return (response.json() or {}).get("status") == "running"
        except ValueError:
            return False

    async def post(self, path: str, params: dict | None = None) -> None:
        """Send a command to the bridge.

        Args:
            path: API path of the command.
            params: Query parameters of the command.

        Raises:
            BridgeError: When the bridge does not answer, has no live connection to the camera, does not offer the
                command or answers with another failure status.
        """
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as http:
                response = await http.post(f"{self.base_url}{path}", params=params)
        except httpx.HTTPError:
            raise BridgeError("The camera bridge does not answer")
        if response.status_code == 503:
            raise BridgeError("The bridge has no live connection to the camera")
        if response.status_code == 404:
            raise BridgeError("The camera bridge does not offer this command")
        if not response.is_success:
            raise BridgeError(f"The camera bridge answered HTTP {response.status_code}")

    async def light(self, mode: str) -> None:
        """Set the light mode of the camera.

        Args:
            mode: One of on, off or auto.

        Raises:
            BridgeError: When the mode is unknown.
        """
        if mode not in LIGHT_MODES:
            raise BridgeError(f"Unknown light mode {mode}")
        await self.post(f"/api/light/{mode}")

    async def siren(self, seconds: int | None) -> None:
        """Sound or silence the siren.

        Args:
            seconds: Seconds to sound the siren, or None or zero to switch it off.
        """
        if seconds:
            await self.post("/api/siren/on", {"seconds": str(seconds)})
        else:
            await self.post("/api/siren/off")
