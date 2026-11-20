"""Cache of ONVIF PTZ targets per camera."""

from dataclasses import dataclass
from uuid import UUID

from adapters.onvif.client import OnvifClient
from adapters.onvif.soap import OnvifError


@dataclass(frozen=True)
class PtzTarget:
    """Everything needed to send PTZ commands to one camera.

    Attributes:
        client: ONVIF client connected to the camera.
        address: Address of the camera's PTZ service.
        profile_token: Token of the media profile that has a PTZ configuration.
    """

    client: OnvifClient
    address: str
    profile_token: str


class OnvifCache:
    """Remember the PTZ target resolved for each camera.

    Attributes:
        targets: Camera UUID to the connection fingerprint and the PTZ target found with it.
    """

    def __init__(self):
        """Create an empty cache."""
        self.targets: dict[UUID, tuple[tuple, PtzTarget]] = {}

    async def ptz_target(
        self,
        camera_uuid: UUID,
        host: str,
        port: int,
        username: str | None,
        password: str | None,
    ) -> PtzTarget:
        """Return the PTZ target of a camera, resolving it on the device when needed.

        The cached target is reused only while the host, port and credentials are unchanged.

        Args:
            camera_uuid: UUID of the camera.
            host: Device host.
            port: ONVIF port of the device.
            username: Device user name, if any.
            password: Device password, if any.

        Returns:
            The PTZ target for the first media profile that has a PTZ configuration.

        Raises:
            OnvifError: When no media profile of the camera has a PTZ configuration.
        """
        fingerprint = (host, port, username or "", password or "")
        entry = self.targets.get(camera_uuid)
        if entry is not None and entry[0] == fingerprint:
            return entry[1]
        client = OnvifClient(host, port, username, password)
        addresses = await client.service_addresses()
        profiles = await client.profiles(addresses.media)
        profile = next((item for item in profiles if item.ptz), None)
        if profile is None:
            raise OnvifError("No media profile of the camera has a PTZ configuration")
        target = PtzTarget(client=client, address=addresses.ptz, profile_token=profile.token)
        self.targets[camera_uuid] = (fingerprint, target)
        return target

    def forget(self, camera_uuid: UUID) -> None:
        """Drop the cached PTZ target of a camera.

        Args:
            camera_uuid: UUID of the camera.
        """
        self.targets.pop(camera_uuid, None)


onvif_cache = OnvifCache()
