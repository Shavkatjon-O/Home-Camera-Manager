"""PTZ commands of the analytics service's auto-follow: moves, stops and the position follow returns to.

Moves go to the camera's own ONVIF device when it offers PTZ there, as PTZ 1 does, and to its V380 bridge otherwise,
as for PTZ 2. Which endpoint and profile serve a camera is remembered for a while, because a camera without device
ONVIF only answers after a timeout and a follow sends several moves a second. The return position is a preset with
a reserved name on cameras that keep presets; on the others saving answers Conflict, and the analytics service
retraces its own moves instead.
"""

import asyncio
import time
from dataclasses import dataclass
from uuid import UUID

from app.core.exceptions import BadGateway, Conflict
from app.models import Camera
from app.modules.control.services import CameraControlService, NotOffered
from app.onvif.endpoints import Connection, bridge_endpoint, device_endpoint
from camera_adapters.onvif import media, ptz
from camera_adapters.onvif.soap import OnvifError

__all__ = ["FOLLOW_PRESET", "FollowPtzService", "MoveTarget"]

FOLLOW_PRESET = "Follow start"
TARGET_SECONDS = 600.0
COMMAND_TIMEOUT = 4.0


@dataclass(frozen=True)
class MoveTarget:
    """Where a camera's moves go.

    Attributes:
        kind: device or bridge.
        profile_token: Token of the media profile with PTZ.
        until: Monotonic time after which the target is looked up again.
    """

    kind: str
    profile_token: str
    until: float


targets: dict[UUID, MoveTarget] = {}


class FollowPtzService(CameraControlService):
    """Sends the follow controller's PTZ commands to a camera."""

    async def move_connection(self, camera: Camera) -> tuple[Connection, str]:
        """Find the endpoint and profile that move a camera.

        Args:
            camera: The camera.

        Returns:
            The open connection and the PTZ profile token.

        Raises:
            Conflict: If neither the device nor the bridge offers PTZ.
        """
        cached = targets.get(camera.uuid)
        kinds = [cached.kind] if cached and cached.until > time.monotonic() else ["device", "bridge"]
        for kind in kinds:
            endpoint = device_endpoint(camera) if kind == "device" else bridge_endpoint(camera)
            if endpoint is None:
                continue
            try:
                connection = await self.open(endpoint)
            except NotOffered:
                continue
            if not connection.address("ptz") or not connection.address(media.MEDIA1):
                continue
            if cached and cached.kind == kind and cached.until > time.monotonic():
                return connection, cached.profile_token
            try:
                profiles = await connection.client.profiles(connection.address(media.MEDIA1))
            except OnvifError:
                continue
            profile = next((item for item in profiles if item.ptz), None)
            if profile is None:
                continue
            targets[camera.uuid] = MoveTarget(kind, profile.token, time.monotonic() + TARGET_SECONDS)
            return connection, profile.token
        targets.pop(camera.uuid, None)
        raise Conflict("ptz_not_supported", "The camera offers no PTZ for following")

    async def send(self, uuid: UUID, pan: float, tilt: float) -> None:
        """Start a continuous move, or stop when both speeds are zero.

        Args:
            uuid: Camera id.
            pan: Pan speed from -1 to 1.
            tilt: Tilt speed from -1 to 1.

        Raises:
            BadGateway: If the camera rejects the command or does not answer in time.
        """
        camera = await self.get(uuid)
        connection, token = await self.move_connection(camera)
        address = connection.address("ptz")
        try:
            if pan or tilt:
                command = connection.client.continuous_move(address, token, pan, tilt, 0.0)
            else:
                command = connection.client.stop(address, token)
            await asyncio.wait_for(command, COMMAND_TIMEOUT)
        except (TimeoutError, OnvifError) as exc:
            targets.pop(camera.uuid, None)
            self.directory.drop(connection.endpoint)
            raise BadGateway("onvif_error", f"The camera did not take the PTZ command: {exc}")

    async def follow_preset(self, uuid: UUID) -> tuple[object, str | None]:
        """Find the camera's preset target and the token of the reserved follow preset.

        Args:
            uuid: Camera id.

        Returns:
            The PTZ preset target and the preset's token, None when it was never saved.

        Raises:
            Conflict: If the camera keeps no presets.
        """
        camera = await self.get(uuid)
        try:
            target = await self.ptz_target(camera)
        except NotOffered as exc:
            raise Conflict("presets_not_supported", str(exc))
        if not target.node.max_presets:
            raise Conflict("presets_not_supported", "The camera keeps no presets")
        body = await self.call(target.connection, "ptz", ptz.presets_body(target.profile_token))
        token = next((item.token for item in ptz.parse_presets(body) if item.name == FOLLOW_PRESET), None)
        return target, token

    async def save_home(self, uuid: UUID) -> None:
        """Store the current position in the reserved follow preset.

        Args:
            uuid: Camera id.

        Raises:
            Conflict: If the camera keeps no presets, so the caller retraces its moves instead.
            BadGateway: If the camera rejects the command.
        """
        target, token = await self.follow_preset(uuid)
        try:
            await asyncio.wait_for(
                self.call(target.connection, "ptz", ptz.set_preset_body(target.profile_token, FOLLOW_PRESET, token)),
                COMMAND_TIMEOUT * 2,
            )
        except (TimeoutError, OnvifError) as exc:
            raise BadGateway("onvif_error", f"The camera did not save the preset: {exc}")

    async def return_home(self, uuid: UUID) -> None:
        """Move back to the reserved follow preset.

        Args:
            uuid: Camera id.

        Raises:
            Conflict: If the camera keeps no presets or the preset was never saved.
            BadGateway: If the camera rejects the command.
        """
        target, token = await self.follow_preset(uuid)
        if token is None:
            raise Conflict("preset_not_found", "The follow start position was never saved")
        try:
            await asyncio.wait_for(
                self.call(target.connection, "ptz", ptz.goto_preset_body(target.profile_token, token)),
                COMMAND_TIMEOUT * 2,
            )
        except (TimeoutError, OnvifError) as exc:
            raise BadGateway("onvif_error", f"The camera did not return to the preset: {exc}")
