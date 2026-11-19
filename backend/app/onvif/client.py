"""Async ONVIF client over SOAP with WS-Security digest, plus parsers for profiles and device time."""

from dataclasses import dataclass, replace
from datetime import UTC, datetime, timedelta
from urllib.parse import urlsplit
from uuid import uuid4
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

import httpx

from app.onvif.digest import security_header
from app.onvif.soap import (
    OnvifError,
    OnvifFault,
    OnvifRefused,
    child,
    descendant,
    descendant_text,
    descendants,
    envelope,
    local_name,
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

SERVICE_NAMESPACES = {
    "http://www.onvif.org/ver10/device/wsdl": "device",
    "http://www.onvif.org/ver10/media/wsdl": "media",
    "http://www.onvif.org/ver20/media/wsdl": "media2",
    "http://www.onvif.org/ver10/events/wsdl": "events",
    "http://www.onvif.org/ver20/imaging/wsdl": "imaging",
    "http://www.onvif.org/ver20/ptz/wsdl": "ptz",
    "http://www.onvif.org/ver20/analytics/wsdl": "analytics",
    "http://www.onvif.org/ver10/recording/wsdl": "recording",
    "http://www.onvif.org/ver10/search/wsdl": "search",
    "http://www.onvif.org/ver10/replay/wsdl": "replay",
    "http://www.onvif.org/ver10/deviceIO/wsdl": "deviceio",
}

CAPABILITY_SERVICES = {
    "Analytics": "analytics",
    "Device": "device",
    "Events": "events",
    "Imaging": "imaging",
    "Media": "media",
    "PTZ": "ptz",
    "DeviceIO": "deviceio",
    "Recording": "recording",
    "Search": "search",
    "Replay": "replay",
}


@dataclass(frozen=True)
class DeviceInfo:
    """Identity a device reports about itself.

    Attributes:
        manufacturer: Manufacturer name.
        model: Model name.
        firmware: Firmware version.
        serial: Serial number.
    """

    manufacturer: str | None = None
    model: str | None = None
    firmware: str | None = None
    serial: str | None = None


@dataclass(frozen=True)
class ServiceAddresses:
    """Addresses of the ONVIF services the camera controls use.

    Attributes:
        media: Address of the media service.
        ptz: Address of the PTZ service.
    """

    media: str
    ptz: str


@dataclass(frozen=True)
class Profile:
    """A media profile of a camera.

    Attributes:
        token: Profile token.
        name: Profile name, the token when the device gives none.
        encoding: Video encoding, such as H264.
        width: Video width in pixels.
        height: Video height in pixels.
        ptz: Whether the profile has a PTZ configuration.
        stream_uri: RTSP stream address, when it has been fetched.
    """

    token: str
    name: str
    encoding: str | None
    width: int | None
    height: int | None
    ptz: bool
    stream_uri: str | None = None

    @property
    def area(self) -> int:
        """Return the resolution of the profile in pixels.

        Returns:
            Width times height, counting a missing value as zero.
        """
        return (self.width or 0) * (self.height or 0)


def addressing_header(action: str, address: str) -> str:
    """Build the WS-Addressing header elements for a request.

    Args:
        action: SOAP action URI.
        address: Address the request is sent to.

    Returns:
        The XML with the action, a new message id and the destination.
    """
    return (
        f"<wsa:Action>{escape(action)}</wsa:Action>"
        f"<wsa:MessageID>urn:uuid:{uuid4()}</wsa:MessageID>"
        f"<wsa:To>{escape(address)}</wsa:To>"
    )


def to_int(value: str | None) -> int | None:
    """Convert text to an integer.

    Args:
        value: Text to convert, or None.

    Returns:
        The integer, or None when the text is missing or not an integer.
    """
    if value is None:
        return None
    try:
        return int(value)
    except ValueError:
        return None


def velocity(value: float) -> str:
    """Format a PTZ velocity component.

    Args:
        value: Velocity, clamped to the range -1 to 1.

    Returns:
        The clamped value with three decimals.
    """
    return f"{max(-1.0, min(1.0, value)):.3f}"


def parse_profiles(body: Element) -> list[Profile]:
    """Read the media profiles from a GetProfiles response.

    Args:
        body: SOAP body of the response.

    Returns:
        The profiles that carry a token, without stream addresses.
    """
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
    """Read the device's UTC time from a GetSystemDateAndTime response.

    Args:
        body: SOAP body of the response.

    Returns:
        The time in UTC, or None when a date or time part is missing or invalid.
    """
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
    """Choose the main and sub streams from profiles that have a stream address.

    Args:
        profiles: Profiles, with or without stream addresses.

    Returns:
        The playable profile with the largest resolution, and the one with the smallest resolution when it is a
        different profile. Each is None when there is no such profile.
    """
    playable = sorted((profile for profile in profiles if profile.stream_uri), key=lambda item: -item.area)
    if not playable:
        return None, None
    main = playable[0]
    sub = playable[-1] if len(playable) > 1 and playable[-1].token != main.token else None
    return main, sub


def uri_path(uri: str) -> tuple[str, int | None]:
    """Split a stream address into its path and port.

    Args:
        uri: Stream address.

    Returns:
        The path with its query string, "/" when the address has no path, and the port or None when it has no
        valid port.
    """
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
    """ONVIF client for one device that sends SOAP over HTTP.

    When a password is set, requests carry a WS-Security digest stamped with the device's own clock.

    Attributes:
        host: Device host.
        port: ONVIF port.
        username: User name, empty when none.
        password: Password, empty when none.
        timeout: Default request timeout in seconds.
        clock_offset: Device clock minus local clock, None until it has been read.
    """

    def __init__(
        self,
        host: str,
        port: int,
        username: str | None = None,
        password: str | None = None,
        timeout: float = DEFAULT_TIMEOUT_SECONDS,
    ):
        """Bind the client to a device.

        Args:
            host: Device host.
            port: ONVIF port.
            username: User name, if any.
            password: Password, if any.
            timeout: Default request timeout in seconds.
        """
        self.host = host
        self.port = port
        self.username = username or ""
        self.password = password or ""
        self.timeout = timeout
        self.clock_offset: timedelta | None = None

    @property
    def base_url(self) -> str:
        """Return the HTTP base address of the device.

        Returns:
            The address built from host and port.
        """
        return f"http://{self.host}:{self.port}"

    @property
    def device_address(self) -> str:
        """Return the address of the device service.

        Returns:
            The base address plus the default device service path.
        """
        return f"{self.base_url}{DEVICE_PATH}"

    def local_address(self, xaddr: str | None, default_path: str) -> str:
        """Rebuild a service address on the host and port this client uses.

        Only the path of the reported address is kept.

        Args:
            xaddr: Address the device reported, or None.
            default_path: Path used when the device reported none.

        Returns:
            The address on this client's host and port.
        """
        path = urlsplit(xaddr).path if xaddr else ""
        return f"{self.base_url}{path or default_path}"

    async def call(
        self,
        address: str,
        body: str,
        secure: bool = True,
        action: str | None = None,
        timeout: float | None = None,
    ) -> Element:
        """Send a SOAP request to the device.

        Args:
            address: Service address to post to.
            body: XML of the request body.
            secure: Whether to add the WS-Security header, which needs a password.
            action: SOAP action URI, WS-Addressing headers are added when given.
            timeout: Request timeout in seconds, the client default when omitted.

        Returns:
            The SOAP Body element of the response.

        Raises:
            OnvifRefused: When the device refuses the connection.
            OnvifError: When the device does not answer, the answer is too large or it is not valid SOAP.
            OnvifFault: When the device answers with a SOAP fault.
        """
        header = await self.security() if secure else ""
        if action:
            header += addressing_header(action, address)
        try:
            async with httpx.AsyncClient(timeout=timeout or self.timeout) as http:
                async with http.stream(
                    "POST", address, content=envelope(body, header), headers={"Content-Type": CONTENT_TYPE}
                ) as response:
                    content = await self.read(response)
                    status_code = response.status_code
        except httpx.ConnectError as exc:
            if "refused" in str(exc).lower():
                raise OnvifRefused(f"The device at {self.host} refuses connections on port {self.port}")
            raise OnvifError(f"The ONVIF service at {self.host}:{self.port} does not answer")
        except httpx.HTTPError:
            raise OnvifError(f"The ONVIF service at {self.host}:{self.port} does not answer")
        return parse_response(content, status_code)

    async def read(self, response: httpx.Response) -> bytes:
        """Read a streamed response body up to the size limit.

        Args:
            response: Streaming HTTP response.

        Returns:
            The body bytes.

        Raises:
            OnvifError: When the body is larger than the limit.
        """
        content = bytearray()
        async for chunk in response.aiter_bytes():
            content.extend(chunk)
            if len(content) > MAX_RESPONSE_BYTES:
                raise OnvifError("The ONVIF answer is too large")
        return bytes(content)

    async def security(self) -> str:
        """Build the security header for a request.

        Tokens are stamped with the device's own time, so the offset of its clock is read once and then reused.

        Returns:
            The WS-Security header, or an empty string when the client has no password.
        """
        if not self.password:
            return ""
        if self.clock_offset is None:
            self.clock_offset = await self.device_clock_offset()
        return security_header(self.username, self.password, datetime.now(UTC) + self.clock_offset)

    async def device_clock_offset(self) -> timedelta:
        """Measure how far the device clock is from the local clock.

        Returns:
            Device time minus local time, zero when the device time cannot be read.
        """
        try:
            device_time = await self.system_date_and_time()
        except OnvifError:
            return timedelta(0)
        if device_time is None:
            return timedelta(0)
        return device_time - datetime.now(UTC)

    async def system_date_and_time(self) -> datetime | None:
        """Read the device's UTC time without authentication.

        Returns:
            The device time, or None when the answer has no valid time.
        """
        body = await self.call(self.device_address, "<tds:GetSystemDateAndTime/>", secure=False)
        return parse_device_time(body)

    async def device_information(self) -> DeviceInfo:
        """Read the identity of the device.

        Returns:
            The manufacturer, model, firmware and serial number.
        """
        body = await self.call(self.device_address, "<tds:GetDeviceInformation/>")
        return DeviceInfo(
            manufacturer=descendant_text(body, "Manufacturer"),
            model=descendant_text(body, "Model"),
            firmware=descendant_text(body, "FirmwareVersion"),
            serial=descendant_text(body, "SerialNumber"),
        )

    async def service_addresses(self) -> ServiceAddresses:
        """Find the media and PTZ service addresses of the device.

        GetCapabilities is tried first and GetServices when the device answers with a fault. Addresses the device
        does not report fall back to the default paths.

        Returns:
            The media and PTZ service addresses on this client's host and port.
        """
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

    async def services(self) -> dict[str, str]:
        """Find the addresses of all the ONVIF services the device offers.

        GetServices is read first, then GetCapabilities fills the services it did not list.

        Returns:
            Service name to service address on this client's host and port.

        Raises:
            OnvifFault: When GetCapabilities faults and GetServices found no service.
        """
        found: dict[str, str] = {}
        try:
            body = await self.call(
                self.device_address,
                "<tds:GetServices><tds:IncludeCapability>false</tds:IncludeCapability></tds:GetServices>",
            )
            for service in descendants(body, "Service"):
                name = SERVICE_NAMESPACES.get(text(child(service, "Namespace")) or "")
                xaddr = text(child(service, "XAddr"))
                if name and xaddr and name not in found:
                    found[name] = self.local_address(xaddr, DEVICE_PATH)
        except OnvifFault:
            pass
        try:
            body = await self.call(
                self.device_address, "<tds:GetCapabilities><tds:Category>All</tds:Category></tds:GetCapabilities>"
            )
        except OnvifFault:
            if found:
                return found
            raise
        capabilities = descendant(body, "Capabilities")
        for element in capabilities.iter() if capabilities is not None else []:
            name = CAPABILITY_SERVICES.get(local_name(element.tag))
            xaddr = text(child(element, "XAddr"))
            if name and xaddr and name not in found:
                found[name] = self.local_address(xaddr, DEVICE_PATH)
        return found

    async def profiles(self, media_address: str) -> list[Profile]:
        """Read the media profiles of the device.

        Args:
            media_address: Address of the media service.

        Returns:
            The profiles without stream addresses.
        """
        body = await self.call(media_address, "<trt:GetProfiles/>")
        return parse_profiles(body)

    async def stream_uri(self, media_address: str, profile_token: str) -> str | None:
        """Read the RTSP stream address of a profile.

        Args:
            media_address: Address of the media service.
            profile_token: Token of the profile.

        Returns:
            The stream address, or None when the answer has none.
        """
        body = await self.call(
            media_address,
            "<trt:GetStreamUri><trt:StreamSetup><tt:Stream>RTP-Unicast</tt:Stream>"
            "<tt:Transport><tt:Protocol>RTSP</tt:Protocol></tt:Transport></trt:StreamSetup>"
            f"<trt:ProfileToken>{escape(profile_token)}</trt:ProfileToken></trt:GetStreamUri>",
        )
        return descendant_text(body, "Uri")

    async def stream_profiles(self) -> list[Profile]:
        """Read every media profile together with its stream address.

        A profile whose stream address request faults is returned without an address.

        Returns:
            The profiles with their stream addresses.
        """
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
        """Start a continuous PTZ move, or stop when every speed is zero.

        Args:
            ptz_address: Address of the PTZ service.
            profile_token: Token of the PTZ profile.
            pan: Pan speed from -1 to 1.
            tilt: Tilt speed from -1 to 1.
            zoom: Zoom speed from -1 to 1.
        """
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
        """Stop pan, tilt and zoom movement.

        Args:
            ptz_address: Address of the PTZ service.
            profile_token: Token of the PTZ profile.
        """
        await self.call(
            ptz_address,
            f"<tptz:Stop><tptz:ProfileToken>{escape(profile_token)}</tptz:ProfileToken>"
            "<tptz:PanTilt>true</tptz:PanTilt><tptz:Zoom>true</tptz:Zoom></tptz:Stop>",
        )
