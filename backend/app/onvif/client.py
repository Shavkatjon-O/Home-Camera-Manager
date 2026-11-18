from dataclasses import dataclass, replace
from datetime import UTC, datetime, timedelta
from urllib.parse import urlsplit
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

import httpx

from app.onvif.digest import security_header
from app.onvif.soap import (
    OnvifError,
    OnvifFault,
    child,
    descendant,
    descendant_text,
    descendants,
    envelope,
    parse_response,
    text,
)

CONTENT_TYPE = "application/soap+xml; charset=utf-8"

DEFAULT_TIMEOUT_SECONDS = 4.0
MAX_RESPONSE_BYTES = 1_048_576

DEVICE_PATH = "/onvif/device_service"
MEDIA_PATH = "/onvif/media_service"
PTZ_PATH = "/onvif/ptz_service"

MEDIA_NAMESPACE = "http://www.onvif.org/ver10/media/wsdl"
PTZ_NAMESPACE = "http://www.onvif.org/ver20/ptz/wsdl"


@dataclass(frozen=True)
class DeviceInfo:
    manufacturer: str | None = None
    model: str | None = None
    firmware: str | None = None
    serial: str | None = None


@dataclass(frozen=True)
class ServiceAddresses:
    media: str
    ptz: str


@dataclass(frozen=True)
class Profile:
    token: str
    name: str
    encoding: str | None
    width: int | None
    height: int | None
    ptz: bool
    stream_uri: str | None = None

    @property
    def area(self) -> int:
        return (self.width or 0) * (self.height or 0)


def to_int(value: str | None) -> int | None:
    if value is None:
        return None
    try:
        return int(value)
    except ValueError:
        return None


def velocity(value: float) -> str:
    return f"{max(-1.0, min(1.0, value)):.3f}"


def parse_profiles(body: Element) -> list[Profile]:
    profiles = []
    for element in descendants(body, "Profiles"):
        token = element.get("token")
        if not token:
            continue
        encoder = child(element, "VideoEncoderConfiguration")
        resolution = child(encoder, "Resolution")
        profiles.append(
            Profile(
                token=token,
                name=text(child(element, "Name")) or token,
                encoding=text(child(encoder, "Encoding")),
                width=to_int(text(child(resolution, "Width"))),
                height=to_int(text(child(resolution, "Height"))),
                ptz=child(element, "PTZConfiguration") is not None,
            )
        )
    return profiles


def parse_device_time(body: Element) -> datetime | None:
    moment = descendant(body, "UTCDateTime")
    date = child(moment, "Date")
    time = child(moment, "Time")
    parts = [
        to_int(text(child(date, "Year"))),
        to_int(text(child(date, "Month"))),
        to_int(text(child(date, "Day"))),
        to_int(text(child(time, "Hour"))),
        to_int(text(child(time, "Minute"))),
        to_int(text(child(time, "Second"))),
    ]
    if any(part is None for part in parts):
        return None
    try:
        return datetime(*parts, tzinfo=UTC)
    except ValueError:
        return None


def pick_streams(profiles: list[Profile]) -> tuple[Profile | None, Profile | None]:
    playable = sorted((profile for profile in profiles if profile.stream_uri), key=lambda item: -item.area)
    if not playable:
        return None, None
    main = playable[0]
    sub = playable[-1] if len(playable) > 1 and playable[-1].token != main.token else None
    return main, sub


def uri_path(uri: str) -> tuple[str, int | None]:
    parts = urlsplit(uri)
    path = parts.path or "/"
    if parts.query:
        path = f"{path}?{parts.query}"
    try:
        port = parts.port
    except ValueError:
        port = None
    return path, port


class OnvifClient:
    def __init__(
        self,
        host: str,
        port: int,
        username: str | None = None,
        password: str | None = None,
        timeout: float = DEFAULT_TIMEOUT_SECONDS,
    ):
        self.host = host
        self.port = port
        self.username = username or ""
        self.password = password or ""
        self.timeout = timeout
        self.clock_offset: timedelta | None = None

    @property
    def base_url(self) -> str:
        return f"http://{self.host}:{self.port}"

    @property
    def device_address(self) -> str:
        return f"{self.base_url}{DEVICE_PATH}"

    def local_address(self, xaddr: str | None, default_path: str) -> str:
        path = urlsplit(xaddr).path if xaddr else ""
        return f"{self.base_url}{path or default_path}"

    async def call(self, address: str, body: str, secure: bool = True) -> Element:
        header = await self.security() if secure else ""
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as http:
                async with http.stream(
                    "POST", address, content=envelope(body, header), headers={"Content-Type": CONTENT_TYPE}
                ) as response:
                    content = await self.read(response)
                    status_code = response.status_code
        except httpx.HTTPError:
            raise OnvifError(f"The ONVIF service at {self.host}:{self.port} does not answer")
        return parse_response(content, status_code)

    async def read(self, response: httpx.Response) -> bytes:
        content = bytearray()
        async for chunk in response.aiter_bytes():
            content.extend(chunk)
            if len(content) > MAX_RESPONSE_BYTES:
                raise OnvifError("The ONVIF answer is too large")
        return bytes(content)

    async def security(self) -> str:
        if not self.password:
            return ""
        if self.clock_offset is None:
            self.clock_offset = await self.device_clock_offset()
        return security_header(self.username, self.password, datetime.now(UTC) + self.clock_offset)

    async def device_clock_offset(self) -> timedelta:
        try:
            device_time = await self.system_date_and_time()
        except OnvifError:
            return timedelta(0)
        if device_time is None:
            return timedelta(0)
        return device_time - datetime.now(UTC)

    async def system_date_and_time(self) -> datetime | None:
        body = await self.call(self.device_address, "<tds:GetSystemDateAndTime/>", secure=False)
        return parse_device_time(body)

    async def device_information(self) -> DeviceInfo:
        body = await self.call(self.device_address, "<tds:GetDeviceInformation/>")
        return DeviceInfo(
            manufacturer=descendant_text(body, "Manufacturer"),
            model=descendant_text(body, "Model"),
            firmware=descendant_text(body, "FirmwareVersion"),
            serial=descendant_text(body, "SerialNumber"),
        )

    async def service_addresses(self) -> ServiceAddresses:
        media = None
        ptz = None
        try:
            body = await self.call(
                self.device_address, "<tds:GetCapabilities><tds:Category>All</tds:Category></tds:GetCapabilities>"
            )
            capabilities = descendant(body, "Capabilities")
            media = text(child(child(capabilities, "Media"), "XAddr"))
            ptz = text(child(child(capabilities, "PTZ"), "XAddr"))
        except OnvifFault:
            try:
                body = await self.call(
                    self.device_address,
                    "<tds:GetServices><tds:IncludeCapability>false</tds:IncludeCapability></tds:GetServices>",
                )
                for service in descendants(body, "Service"):
                    namespace = text(child(service, "Namespace"))
                    if namespace == MEDIA_NAMESPACE:
                        media = text(child(service, "XAddr"))
                    elif namespace == PTZ_NAMESPACE:
                        ptz = text(child(service, "XAddr"))
            except OnvifFault:
                pass
        return ServiceAddresses(
            media=self.local_address(media, MEDIA_PATH),
            ptz=self.local_address(ptz, PTZ_PATH),
        )

    async def profiles(self, media_address: str) -> list[Profile]:
        body = await self.call(media_address, "<trt:GetProfiles/>")
        return parse_profiles(body)

    async def stream_uri(self, media_address: str, profile_token: str) -> str | None:
        body = await self.call(
            media_address,
            "<trt:GetStreamUri><trt:StreamSetup><tt:Stream>RTP-Unicast</tt:Stream>"
            "<tt:Transport><tt:Protocol>RTSP</tt:Protocol></tt:Transport></trt:StreamSetup>"
            f"<trt:ProfileToken>{escape(profile_token)}</trt:ProfileToken></trt:GetStreamUri>",
        )
        return descendant_text(body, "Uri")

    async def stream_profiles(self) -> list[Profile]:
        addresses = await self.service_addresses()
        profiles = await self.profiles(addresses.media)
        result = []
        for profile in profiles:
            try:
                uri = await self.stream_uri(addresses.media, profile.token)
            except OnvifFault:
                uri = None
            result.append(replace(profile, stream_uri=uri))
        return result

    async def continuous_move(self, ptz_address: str, profile_token: str, pan: float, tilt: float, zoom: float) -> None:
        parts = []
        if pan or tilt:
            parts.append(f'<tt:PanTilt x="{velocity(pan)}" y="{velocity(tilt)}"/>')
        if zoom:
            parts.append(f'<tt:Zoom x="{velocity(zoom)}"/>')
        if not parts:
            await self.stop(ptz_address, profile_token)
            return
        await self.call(
            ptz_address,
            f"<tptz:ContinuousMove><tptz:ProfileToken>{escape(profile_token)}</tptz:ProfileToken>"
            f"<tptz:Velocity>{''.join(parts)}</tptz:Velocity></tptz:ContinuousMove>",
        )

    async def stop(self, ptz_address: str, profile_token: str) -> None:
        await self.call(
            ptz_address,
            f"<tptz:Stop><tptz:ProfileToken>{escape(profile_token)}</tptz:ProfileToken>"
            "<tptz:PanTilt>true</tptz:PanTilt><tptz:Zoom>true</tptz:Zoom></tptz:Stop>",
        )
