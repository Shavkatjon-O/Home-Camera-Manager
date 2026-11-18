from dataclasses import dataclass
from uuid import UUID

from app.onvif.client import OnvifClient
from app.onvif.soap import OnvifError


@dataclass(frozen=True)
class PtzTarget:
    client: OnvifClient
    address: str
    profile_token: str


class OnvifCache:
    def __init__(self):
        self.targets: dict[UUID, tuple[tuple, PtzTarget]] = {}

    async def ptz_target(
        self,
        camera_uuid: UUID,
        host: str,
        port: int,
        username: str | None,
        password: str | None,
    ) -> PtzTarget:
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
        self.targets.pop(camera_uuid, None)


onvif_cache = OnvifCache()
