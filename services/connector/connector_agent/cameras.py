"""The cameras the connector serves: their encrypted credentials, their go2rtc streams, tests and control."""

import asyncio
import logging
from dataclasses import replace
from urllib.parse import quote
from uuid import UUID

from camera_adapters.base import AdapterError, ControlCapability, Identity, Target
from camera_adapters.fingerprint import collect
from camera_adapters.registry import Registry, default_registry
from camera_adapters.rtsp.describe import describe
from camera_adapters.sweep import port_open

from connector_agent.go2rtc import Go2rtc
from connector_agent.state import CameraEntry, Credentials, Store

__all__ = ["CameraManager", "identity_json", "rtsp_source", "stream_names"]

logger = logging.getLogger(__name__)

PROBE_TIMEOUT_SECONDS = 2.0


def stream_names(uuid: str) -> tuple[str, str]:
    """Name a camera's go2rtc streams the way central names them.

    Args:
        uuid: Camera id.

    Returns:
        The main and sub stream names.
    """
    hexed = UUID(uuid).hex
    return f"{hexed}_main", f"{hexed}_sub"


def rtsp_source(camera: CameraEntry, path: str) -> str:
    """Build a camera's RTSP address with its credentials.

    Args:
        camera: The camera.
        path: Stream path.

    Returns:
        The address.
    """
    secret = ""
    if camera.credentials.username:
        secret = quote(camera.credentials.username, safe="")
        if camera.credentials.password:
            secret = f"{secret}:{quote(camera.credentials.password, safe='')}"
        secret = f"{secret}@"
    if not path.startswith("/"):
        path = f"/{path}"
    return f"rtsp://{secret}{camera.host}:{camera.rtsp_port}{path}"


def identity_json(identity: Identity) -> dict:
    """Turn an identity into the JSON the backend reads, without the serial number.

    Args:
        identity: The identity.

    Returns:
        The identity as JSON.
    """
    return {
        "adapter": identity.adapter,
        "kind": identity.kind.value,
        "vendor": identity.vendor,
        "model": identity.model,
        "firmware": identity.firmware,
        "rtsp_port": identity.rtsp_port,
        "channels": [
            {
                "index": channel.index,
                "name": channel.name,
                "token": channel.token,
                "main_path": channel.main_path,
                "sub_path": channel.sub_path,
                "width": channel.width,
                "height": channel.height,
                "encoding": channel.encoding,
                "ptz": channel.ptz,
            }
            for channel in identity.channels
        ],
        "manifest": identity.manifest.to_dict(),
    }


class CameraManager:
    """Keeps the cameras, their credentials and their go2rtc streams.

    Attributes:
        store: The encrypted store.
        go2rtc: The connector's go2rtc.
        registry: Adapter registry.
        cameras: Camera id to camera.
        lock: Lock serialising changes.
    """

    def __init__(self, store: Store, go2rtc: Go2rtc, registry: Registry | None = None):
        """Load the stored cameras.

        Args:
            store: The encrypted store.
            go2rtc: The connector's go2rtc.
            registry: Adapter registry, the default one when omitted.
        """
        self.store = store
        self.go2rtc = go2rtc
        self.registry = registry or default_registry()
        self.cameras = store.cameras()
        self.lock = asyncio.Lock()

    def desired(self) -> dict[str, list[str]]:
        """Build the go2rtc streams the cameras need.

        Returns:
            Stream name to its source, for every enabled camera.
        """
        streams = {}
        for camera in self.cameras.values():
            if not camera.enabled:
                continue
            main, sub = stream_names(camera.uuid)
            streams[main] = [rtsp_source(camera, camera.main_path)]
            if camera.sub_path:
                streams[sub] = [rtsp_source(camera, camera.sub_path)]
        return streams

    async def sync(self) -> None:
        """Bring go2rtc in line with the cameras, logging a failure."""
        try:
            await self.go2rtc.apply(self.desired())
        except Exception as exc:
            logger.warning("Updating go2rtc failed: %s", exc)

    async def put(self, uuid: str, config: dict) -> CameraEntry:
        """Store a camera handed over by central, keeping its stored password unless a new one is given.

        Args:
            uuid: Camera id.
            config: Camera fields; a password of None keeps the stored one, an empty one removes it.

        Returns:
            The camera.
        """
        async with self.lock:
            old = self.cameras.get(uuid)
            credentials = old.credentials if old else Credentials()
            password = config.get("password")
            credentials = Credentials(
                username=config.get("username") if config.get("username") is not None else credentials.username,
                password=credentials.password if password is None else (password or None),
                device_id=config.get("device_id") or credentials.device_id,
            )
            camera = CameraEntry(
                uuid=uuid,
                name=str(config.get("name") or "Camera"),
                brand=str(config.get("brand") or "rtsp"),
                host=str(config["host"]),
                rtsp_port=int(config.get("rtsp_port") or 554),
                onvif_port=config.get("onvif_port"),
                main_path=str(config["main_path"]),
                sub_path=config.get("sub_path"),
                enabled=bool(config.get("enabled", True)),
                channel=int(config.get("channel") or 1),
                credentials=credentials,
            )
            self.cameras[uuid] = camera
            self.store.save_cameras(self.cameras)
        await self.sync()
        return camera

    async def delete(self, uuid: str) -> None:
        """Remove a camera and its credentials.

        Args:
            uuid: Camera id.
        """
        async with self.lock:
            if self.cameras.pop(uuid, None) is not None:
                self.store.save_cameras(self.cameras)
        await self.sync()

    async def reconcile(self, config: dict) -> None:
        """Bring the stored cameras in line with central's list, keeping the credentials held here.

        Args:
            config: Central's camera list, without credentials.
        """
        async with self.lock:
            wanted = {str(item["uuid"]): item for item in config.get("cameras") or []}
            for uuid in [uuid for uuid in self.cameras if uuid not in wanted]:
                self.cameras.pop(uuid)
            for uuid, item in wanted.items():
                current = self.cameras.get(uuid)
                credentials = current.credentials if current else Credentials()
                self.cameras[uuid] = CameraEntry(
                    uuid=uuid,
                    name=str(item.get("name") or "Camera"),
                    brand=str(item.get("brand") or "rtsp"),
                    host=str(item["host"]),
                    rtsp_port=int(item.get("rtsp_port") or 554),
                    onvif_port=item.get("onvif_port"),
                    main_path=str(item["main_path"]),
                    sub_path=item.get("sub_path"),
                    enabled=bool(item.get("enabled", True)),
                    channel=int(item.get("channel") or 1),
                    credentials=credentials,
                )
            self.store.save_cameras(self.cameras)
        await self.sync()

    async def status(self) -> list[dict]:
        """Probe every enabled camera's RTSP port.

        Returns:
            Camera id, whether it answers and the reason when it does not.
        """

        async def one(camera: CameraEntry) -> dict:
            """Probe one camera.

            Args:
                camera: The camera.

            Returns:
                Its status.
            """
            online = await port_open(camera.host, camera.rtsp_port, PROBE_TIMEOUT_SECONDS)
            return {"uuid": camera.uuid, "online": online, "error": None if online else "The camera does not answer"}

        return list(await asyncio.gather(*(one(camera) for camera in self.cameras.values() if camera.enabled)))

    def target(self, request: dict) -> Target:
        """Build an adapter target from a request.

        Args:
            request: Address, ports, credentials and paths.

        Returns:
            The target.
        """
        return Target(
            host=str(request.get("host") or ""),
            port=request.get("port") or request.get("onvif_port"),
            rtsp_port=request.get("rtsp_port"),
            username=request.get("username"),
            password=request.get("password"),
            device_id=request.get("device_id"),
            main_path=request.get("main_path"),
            sub_path=request.get("sub_path"),
            url=request.get("rtsp_url"),
        )

    async def identify(self, request: dict) -> dict:
        """Identify a device on the site's network with the adapter registry.

        Args:
            request: Address, ports, credentials, adapter and stream address.

        Returns:
            The identity as JSON.

        Raises:
            AdapterError: No adapter could identify the device.
        """
        target = self.target(request)
        adapter = "rtsp" if target.url else request.get("adapter")
        if target.url and not target.host:
            target = replace(target, host="rtsp")
        fingerprint = None if adapter else await collect(target.host)
        identity, _ = await self.registry.identify(target, fingerprint, adapter)
        return identity_json(identity)

    async def test(self, request: dict) -> dict:
        """Test a camera's login and find its streams.

        Args:
            request: Address, brand, ports, credentials and known paths.

        Returns:
            Whether the main stream answers, the paths and PTZ support found, and the reason of a failure.
        """
        brand = str(request.get("brand") or "onvif")
        try:
            target = self.target(request)
            adapter = self.registry.get(brand) if brand in self.registry.adapters else self.registry.get("onvif")
            ptz = None
            vendor = model = None
            if not target.main_path:
                identity = await adapter.identify(target)
                first = identity.channels[0]
                target = replace(target, main_path=first.main_path, sub_path=target.sub_path or first.sub_path)
                target = replace(target, rtsp_port=target.rtsp_port or identity.rtsp_port)
                ptz, vendor, model = first.ptz, identity.vendor, identity.model
            url = f"rtsp://{target.host}:{target.rtsp_port or 554}{target.main_path}"
            await describe(url, target.username, target.password)
        except AdapterError as exc:
            return {"ok": False, "error": exc.message}
        return {
            "ok": True,
            "rtsp_port": target.rtsp_port or 554,
            "main_path": target.main_path,
            "sub_path": target.sub_path,
            "ptz": ptz,
            "manufacturer": vendor,
            "model": model,
        }

    def control(self, uuid: str) -> tuple[ControlCapability, Target, int]:
        """Find the adapter, target and channel that move a camera.

        Args:
            uuid: Camera id.

        Returns:
            The adapter, the target and the channel.

        Raises:
            AdapterError: The camera is unknown or its adapter cannot move it.
        """
        camera = self.cameras.get(uuid)
        if camera is None:
            raise AdapterError("invalid", f"Camera {uuid} is not on this connector")
        adapter = self.registry.adapters.get(camera.brand) or self.registry.get("onvif")
        if not isinstance(adapter, ControlCapability):
            raise AdapterError("unsupported", "The camera cannot be moved")
        target = Target(
            host=camera.host,
            port=camera.onvif_port,
            rtsp_port=camera.rtsp_port,
            username=camera.credentials.username,
            password=camera.credentials.password,
            device_id=camera.credentials.device_id,
        )
        return adapter, target, camera.channel
