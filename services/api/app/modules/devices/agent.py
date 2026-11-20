"""Client of a connector's agent API, which central calls at the connector's address in either mode."""

from uuid import UUID

import httpx

from app.core.exceptions import BadGateway, Conflict
from app.core.security import decrypt_secret
from app.models import Connector
from app.modules.devices.enums import ConnectorMode

__all__ = ["AgentClient", "agent_address"]

AGENT_TIMEOUT_SECONDS = 20.0


def agent_address(connector: Connector) -> str | None:
    """Return the address central reaches a connector at.

    Direct mode and tunnel mode differ only here: the reported or configured address in direct mode, the overlay
    address in tunnel mode.

    Args:
        connector: The connector.

    Returns:
        The address, or None while the connector has not reported one.
    """
    if connector.mode == ConnectorMode.TUNNEL.value:
        return connector.tunnel_address
    return connector.address


class AgentClient:
    """Calls one connector's agent with the key central received at pairing.

    Attributes:
        connector: The connector.
        transport: HTTP transport, replaced in tests.
    """

    def __init__(self, connector: Connector, transport: httpx.AsyncBaseTransport | None = None):
        """Bind the client to a connector.

        Args:
            connector: The connector.
            transport: HTTP transport, the default when omitted.
        """
        self.connector = connector
        self.transport = transport

    def base_url(self) -> str:
        """Return the agent's base address.

        Returns:
            The address with the agent port.

        Raises:
            Conflict: The connector has not reported an address yet.
        """
        address = agent_address(self.connector)
        if not address:
            raise Conflict("connector_offline", "The connector has not reported an address yet")
        return f"http://{address}:{self.connector.api_port}"

    async def call(self, method: str, path: str, body: dict | None = None) -> dict:
        """Send one request to the agent.

        Args:
            method: HTTP method.
            path: Path under /api.
            body: JSON body, if any.

        Returns:
            The JSON answer, empty for an empty one.

        Raises:
            BadGateway: The agent cannot be reached or refuses the request.
        """
        key = decrypt_secret(self.connector.agent_key_encrypted) or ""
        try:
            async with httpx.AsyncClient(
                base_url=self.base_url(), timeout=AGENT_TIMEOUT_SECONDS, transport=self.transport
            ) as http:
                response = await http.request(
                    method, f"/api{path}", json=body, headers={"Authorization": f"Bearer {key}"}
                )
        except httpx.HTTPError as exc:
            raise BadGateway("connector_unreachable", f"The connector does not answer ({type(exc).__name__})")
        if not response.is_success:
            message = response.text[:200] if response.text else f"HTTP {response.status_code}"
            raise BadGateway("connector_refused", f"The connector refused the request: {message}")
        if not response.content:
            return {}
        try:
            return response.json()
        except ValueError:
            raise BadGateway("connector_refused", "The connector answered with invalid JSON")

    async def put_camera(self, camera_uuid: UUID, config: dict) -> dict:
        """Hand a camera with its credentials to the connector.

        Args:
            camera_uuid: Camera id.
            config: Camera fields; a password of None keeps the one the connector holds, an empty one removes it.

        Returns:
            The agent's answer.
        """
        return await self.call("PUT", f"/cameras/{camera_uuid}", config)

    async def delete_camera(self, camera_uuid: UUID) -> None:
        """Remove a camera and its credentials from the connector.

        Args:
            camera_uuid: Camera id.
        """
        await self.call("DELETE", f"/cameras/{camera_uuid}")

    async def test_camera(self, request: dict) -> dict:
        """Ask the connector to test a camera's credentials and find its streams.

        Args:
            request: Address, brand, ports, credentials and known paths.

        Returns:
            The test result.
        """
        return await self.call("POST", "/cameras/test", request)

    async def ptz(self, camera_uuid: UUID, pan: float, tilt: float, zoom: float) -> None:
        """Start a continuous PTZ move through the connector.

        Args:
            camera_uuid: Camera id.
            pan: Pan speed.
            tilt: Tilt speed.
            zoom: Zoom speed.
        """
        await self.call("POST", f"/cameras/{camera_uuid}/ptz/move", {"pan": pan, "tilt": tilt, "zoom": zoom})

    async def ptz_stop(self, camera_uuid: UUID) -> None:
        """Stop a PTZ move through the connector.

        Args:
            camera_uuid: Camera id.
        """
        await self.call("POST", f"/cameras/{camera_uuid}/ptz/stop")

    async def discover(self) -> None:
        """Ask the connector to run discovery now."""
        await self.call("POST", "/discovery")
