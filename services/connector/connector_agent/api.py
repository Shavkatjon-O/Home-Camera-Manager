"""The agent API central calls with the agent key: cameras, tests, identification, PTZ and discovery."""

import hmac
from collections.abc import Callable
from typing import Annotated

from camera_adapters.base import AdapterError
from fastapi import Depends, FastAPI, Header, HTTPException, Response, status
from pydantic import BaseModel, Field

__all__ = ["CameraConfig", "PtzMove", "create_app"]


class CameraConfig(BaseModel):
    """A camera central hands over, with its credentials.

    Attributes:
        name: Display name.
        brand: Adapter name.
        host: Address on the site's network.
        rtsp_port: RTSP port.
        onvif_port: Control port, if any.
        main_path: Main stream path.
        sub_path: Sub stream path, if any.
        enabled: Whether to stream it.
        username: Camera login.
        password: Camera password; None keeps the stored one and an empty one removes it.
        device_id: Device id of a V380 camera.
        channel: Channel of the camera on its device.
    """

    name: str = Field(min_length=1, max_length=100)
    brand: str = Field(default="rtsp", max_length=40)
    host: str = Field(min_length=1, max_length=255)
    rtsp_port: int = Field(default=554, ge=1, le=65535)
    onvif_port: int | None = Field(default=None, ge=1, le=65535)
    main_path: str = Field(min_length=1, max_length=255)
    sub_path: str | None = Field(default=None, max_length=255)
    enabled: bool = True
    username: str | None = Field(default=None, max_length=100)
    password: str | None = Field(default=None, max_length=256)
    device_id: str | None = Field(default=None, max_length=40)
    channel: int = Field(default=1, ge=1, le=256)


class PtzMove(BaseModel):
    """A continuous PTZ move.

    Attributes:
        pan: Pan speed from -1 to 1.
        tilt: Tilt speed from -1 to 1.
        zoom: Zoom speed from -1 to 1.
    """

    pan: float = Field(default=0, ge=-1, le=1)
    tilt: float = Field(default=0, ge=-1, le=1)
    zoom: float = Field(default=0, ge=-1, le=1)


def adapter_error(exc: AdapterError) -> dict:
    """Describe an adapter failure the way central reads it.

    Args:
        exc: The failure.

    Returns:
        The error with its stable code and message.
    """
    return {"error": {"code": exc.code, "message": exc.message}}


def create_app(agent) -> FastAPI:
    """Build the agent API around a running agent.

    Args:
        agent: The agent, with its settings, store, camera manager, pairing state and discovery trigger.

    Returns:
        The application.
    """
    app = FastAPI(title="Smart Surveillance connector agent", openapi_url=None, docs_url=None, redoc_url=None)

    def authorise(authorization: Annotated[str | None, Header()] = None) -> None:
        """Check central's agent key.

        Args:
            authorization: The Authorization header.

        Raises:
            HTTPException: The connector is not paired or the key is wrong.
        """
        pairing = agent.store.pairing()
        if pairing is None:
            raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "The connector is not paired")
        expected = f"Bearer {pairing.agent_key}"
        if not authorization or not hmac.compare_digest(authorization.encode(), expected.encode()):
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "The agent key is wrong")

    guarded: list[Callable] = [Depends(authorise)]

    @app.get("/health")
    async def health() -> dict:
        """Report whether the agent runs and is paired, for the container health check.

        Returns:
            The state.
        """
        return {"status": "ok", "paired": agent.store.pairing() is not None}

    @app.get("/pairing")
    async def pairing() -> dict:
        """Show the pending pairing code to someone on the site's network.

        Returns:
            The code and the link that claims it, or the paired state.
        """
        pending = agent.pending
        if agent.store.pairing() is not None or pending is None:
            return {"paired": agent.store.pairing() is not None}
        return {
            "paired": False,
            "user_code": pending["user_code"],
            "verification_uri_complete": pending["verification_uri_complete"],
        }

    @app.get("/pairing.svg")
    async def pairing_qr() -> Response:
        """Render the pending pairing link as a QR code.

        Returns:
            The SVG image.

        Raises:
            HTTPException: Nothing waits for pairing.
        """
        if agent.pending is None or agent.store.pairing() is not None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Nothing waits for pairing")
        return Response(agent.pairing_qr_svg(), media_type="image/svg+xml")

    @app.put("/api/cameras/{uuid}", dependencies=guarded)
    async def put_camera(uuid: str, config: CameraConfig) -> dict:
        """Store a camera and stream it.

        Args:
            uuid: Camera id.
            config: The camera with its credentials.

        Returns:
            The camera without its credentials.
        """
        camera = await agent.cameras.put(uuid, config.model_dump())
        return {"uuid": camera.uuid, "enabled": camera.enabled}

    @app.delete("/api/cameras/{uuid}", status_code=status.HTTP_204_NO_CONTENT, dependencies=guarded)
    async def delete_camera(uuid: str) -> Response:
        """Remove a camera and its credentials.

        Args:
            uuid: Camera id.

        Returns:
            An empty answer.
        """
        await agent.cameras.delete(uuid)
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    @app.post("/api/cameras/test", dependencies=guarded)
    async def test_camera(request: dict) -> dict:
        """Test a camera's login and find its streams.

        Args:
            request: Address, brand, ports, credentials and paths.

        Returns:
            The result.
        """
        return await agent.cameras.test(request)

    @app.post("/api/identify", dependencies=guarded)
    async def identify(request: dict) -> dict:
        """Identify a device on the site's network with the adapter registry.

        Args:
            request: Address, ports, credentials, adapter and stream address.

        Returns:
            The identity, or the adapter's error with its stable code.
        """
        try:
            return await agent.cameras.identify(request)
        except AdapterError as exc:
            return adapter_error(exc)

    @app.post("/api/cameras/{uuid}/ptz/move", status_code=status.HTTP_204_NO_CONTENT, dependencies=guarded)
    async def ptz_move(uuid: str, move: PtzMove) -> Response:
        """Move a camera continuously.

        Args:
            uuid: Camera id.
            move: Speeds.

        Returns:
            An empty answer.

        Raises:
            HTTPException: The camera is unknown or cannot move.
        """
        try:
            adapter, target, channel = agent.cameras.control(uuid)
            await adapter.move(target, channel, move.pan, move.tilt, move.zoom)
        except AdapterError as exc:
            raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, exc.message)
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    @app.post("/api/cameras/{uuid}/ptz/stop", status_code=status.HTTP_204_NO_CONTENT, dependencies=guarded)
    async def ptz_stop(uuid: str) -> Response:
        """Stop a camera's move.

        Args:
            uuid: Camera id.

        Returns:
            An empty answer.

        Raises:
            HTTPException: The camera is unknown or cannot move.
        """
        try:
            adapter, target, channel = agent.cameras.control(uuid)
            await adapter.stop(target, channel)
        except AdapterError as exc:
            raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, exc.message)
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    @app.post("/api/discovery", status_code=status.HTTP_202_ACCEPTED, dependencies=guarded)
    async def discovery() -> dict:
        """Start a discovery run that reports its result to the backend.

        Returns:
            Whether a run started now or one was already running.
        """
        return {"started": agent.request_discovery()}

    return app
