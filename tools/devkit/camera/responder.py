"""ONVIF and WS-Discovery responder for one simulated IP camera."""

import base64
import hashlib
import hmac
import os
import socket
import struct
import threading
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import quote
from xml.etree import ElementTree
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

SOAP = "http://www.w3.org/2003/05/soap-envelope"
TDS = "http://www.onvif.org/ver10/device/wsdl"
TRT = "http://www.onvif.org/ver10/media/wsdl"
TPTZ = "http://www.onvif.org/ver20/ptz/wsdl"
TT = "http://www.onvif.org/ver10/schema"
TER = "http://www.onvif.org/ver10/error"
DN = "http://www.onvif.org/ver10/network/wsdl"
WSA = "http://schemas.xmlsoap.org/ws/2004/08/addressing"
WSD = "http://schemas.xmlsoap.org/ws/2005/04/discovery"

ANONYMOUS = "http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous"
PROBE_MATCHES_ACTION = "http://schemas.xmlsoap.org/ws/2005/04/discovery/ProbeMatches"

DISCOVERY_GROUP = "239.255.255.250"
DISCOVERY_PORT = 3702
HTTP_PORT = 80
RTSP_PORT = 554

CONTENT_TYPE = "application/soap+xml; charset=utf-8"
PROBE_TYPES = {"NetworkVideoTransmitter", "Device"}


@dataclass(frozen=True)
class Config:
    """Settings of one simulated camera.

    Attributes:
        name: Display name the camera reports.
        manufacturer: Manufacturer the camera reports.
        model: Model the camera reports.
        serial: Serial number the camera reports.
        address: IPv4 address of the camera on the site LAN.
        username: User name required when a password is set.
        password: Password, empty for a camera without authentication.
        ptz: Whether the camera offers PTZ.
        main_size: Width and height of the main stream.
        sub_size: Width and height of the sub stream, None for a camera without one.
    """

    name: str
    manufacturer: str
    model: str
    serial: str
    address: str
    username: str
    password: str
    ptz: bool
    main_size: tuple[int, int]
    sub_size: tuple[int, int] | None

    @property
    def device_xaddr(self) -> str:
        """Return the address of the device service.

        Returns:
            The HTTP address of the device service.
        """
        return f"http://{self.address}:{HTTP_PORT}/onvif/device_service"

    @property
    def media_xaddr(self) -> str:
        """Return the address of the media service.

        Returns:
            The HTTP address of the media service.
        """
        return f"http://{self.address}:{HTTP_PORT}/onvif/media_service"

    @property
    def ptz_xaddr(self) -> str:
        """Return the address of the PTZ service.

        Returns:
            The HTTP address of the PTZ service.
        """
        return f"http://{self.address}:{HTTP_PORT}/onvif/ptz_service"

    @property
    def endpoint(self) -> str:
        """Return the stable WS-Discovery endpoint reference of the camera.

        Returns:
            A urn:uuid value derived from the serial number.
        """
        return f"urn:uuid:{uuid.uuid5(uuid.NAMESPACE_DNS, self.serial)}"


def parse_size(value: str | None) -> tuple[int, int] | None:
    """Parse a WIDTHxHEIGHT value.

    Args:
        value: Text such as 1280x720, or None.

    Returns:
        Width and height, or None when the value is empty.

    Raises:
        ValueError: When the value is not two integers joined by x.
    """
    if not value:
        return None
    width, height = value.lower().split("x")
    return int(width), int(height)


def load_config(environ: dict[str, str]) -> Config:
    """Build the camera settings from environment variables.

    Args:
        environ: Environment mapping.

    Returns:
        The settings of the camera.

    Raises:
        KeyError: When CAMERA_ADDRESS is not set.
    """
    address = environ["CAMERA_ADDRESS"]
    name = environ.get("CAMERA_NAME") or f"camera-{address}"
    return Config(
        name=name,
        manufacturer=environ.get("CAMERA_MANUFACTURER", "Simulated"),
        model=environ.get("CAMERA_MODEL", "SIM-1"),
        serial=environ.get("CAMERA_SERIAL") or f"SIM-{address.replace('.', '-')}",
        address=address,
        username=environ.get("CAMERA_USERNAME", "admin"),
        password=environ.get("CAMERA_PASSWORD", ""),
        ptz=environ.get("CAMERA_PTZ", "false").lower() == "true",
        main_size=parse_size(environ.get("CAMERA_MAIN_SIZE")) or (1280, 720),
        sub_size=parse_size(environ.get("CAMERA_SUB_SIZE")),
    )


def local_name(tag: str) -> str:
    """Strip the namespace from an element tag.

    Args:
        tag: Tag in the form "{namespace}name" or "name".

    Returns:
        The tag without its namespace.
    """
    return tag.rsplit("}", 1)[-1]


def find(element: Element | None, name: str) -> Element | None:
    """Find the first descendant with a local name.

    Args:
        element: Element to search below, or None.
        name: Local name to look for.

    Returns:
        The element, or None when there is none.
    """
    if element is None:
        return None
    for item in element.iter():
        if item is not element and local_name(item.tag) == name:
            return item
    return None


def find_text(element: Element | None, name: str) -> str:
    """Return the stripped text of the first descendant with a local name.

    Args:
        element: Element to search below, or None.
        name: Local name to look for.

    Returns:
        The text, empty when the element is missing.
    """
    item = find(element, name)
    return (item.text or "").strip() if item is not None else ""


def envelope(body: str) -> bytes:
    """Wrap a response body in a SOAP envelope.

    Args:
        body: XML placed inside the SOAP body.

    Returns:
        The UTF-8 encoded XML document.
    """
    declarations = (
        f'xmlns:s="{SOAP}" xmlns:tds="{TDS}" xmlns:trt="{TRT}" xmlns:tptz="{TPTZ}" xmlns:tt="{TT}" xmlns:ter="{TER}"'
    )
    document = f"<s:Envelope {declarations}><s:Body>{body}</s:Body></s:Envelope>"
    return f'<?xml version="1.0" encoding="UTF-8"?>{document}'.encode()


def fault(subcode: str, reason: str) -> tuple[int, bytes]:
    """Build a SOAP fault answer.

    Args:
        subcode: Fault subcode with its prefix, such as ter:NotAuthorized.
        reason: Human readable reason.

    Returns:
        The HTTP status 400 and the fault envelope.
    """
    body = (
        "<s:Fault><s:Code><s:Value>s:Sender</s:Value>"
        f"<s:Subcode><s:Value>{subcode}</s:Value></s:Subcode></s:Code>"
        f'<s:Reason><s:Text xml:lang="en">{escape(reason)}</s:Text></s:Reason></s:Fault>'
    )
    return 400, envelope(body)


def authorized(config: Config, root: Element) -> bool:
    """Check the WS-Security UsernameToken of a request.

    Args:
        config: Camera settings.
        root: Parsed SOAP envelope.

    Returns:
        True when the camera has no password or the token carries the correct digest.
    """
    if not config.password:
        return True
    token = find(root, "UsernameToken")
    if token is None:
        return False
    if find_text(token, "Username") != config.username:
        return False
    nonce_text = find_text(token, "Nonce")
    created = find_text(token, "Created")
    sent = find_text(token, "Password")
    try:
        nonce = base64.b64decode(nonce_text, validate=True)
    except ValueError:
        return False
    digest = hashlib.sha1(nonce + created.encode() + config.password.encode()).digest()
    return hmac.compare_digest(base64.b64encode(digest).decode(), sent)


def system_date_and_time() -> str:
    """Build the GetSystemDateAndTime answer.

    Returns:
        The response body with the current UTC time.
    """
    now = datetime.now(UTC)
    return (
        "<tds:GetSystemDateAndTimeResponse><tds:SystemDateAndTime>"
        "<tt:DateTimeType>NTP</tt:DateTimeType><tt:DaylightSavings>false</tt:DaylightSavings><tt:UTCDateTime>"
        f"<tt:Time><tt:Hour>{now.hour}</tt:Hour><tt:Minute>{now.minute}</tt:Minute><tt:Second>{now.second}</tt:Second></tt:Time>"
        f"<tt:Date><tt:Year>{now.year}</tt:Year><tt:Month>{now.month}</tt:Month><tt:Day>{now.day}</tt:Day></tt:Date>"
        "</tt:UTCDateTime></tds:SystemDateAndTime></tds:GetSystemDateAndTimeResponse>"
    )


def device_information(config: Config) -> str:
    """Build the GetDeviceInformation answer.

    Args:
        config: Camera settings.

    Returns:
        The response body.
    """
    return (
        "<tds:GetDeviceInformationResponse>"
        f"<tds:Manufacturer>{escape(config.manufacturer)}</tds:Manufacturer>"
        f"<tds:Model>{escape(config.model)}</tds:Model>"
        "<tds:FirmwareVersion>1.0.0</tds:FirmwareVersion>"
        f"<tds:SerialNumber>{escape(config.serial)}</tds:SerialNumber>"
        f"<tds:HardwareId>{escape(config.model)}-HW</tds:HardwareId>"
        "</tds:GetDeviceInformationResponse>"
    )


def capabilities(config: Config) -> str:
    """Build the GetCapabilities answer.

    Args:
        config: Camera settings.

    Returns:
        The response body.
    """
    ptz = f"<tt:PTZ><tt:XAddr>{config.ptz_xaddr}</tt:XAddr></tt:PTZ>" if config.ptz else ""
    return (
        "<tds:GetCapabilitiesResponse><tds:Capabilities>"
        f"<tt:Device><tt:XAddr>{config.device_xaddr}</tt:XAddr></tt:Device>"
        f"<tt:Media><tt:XAddr>{config.media_xaddr}</tt:XAddr></tt:Media>"
        f"{ptz}</tds:Capabilities></tds:GetCapabilitiesResponse>"
    )


def services(config: Config) -> str:
    """Build the GetServices answer.

    Args:
        config: Camera settings.

    Returns:
        The response body.
    """
    entries = [
        (TDS, config.device_xaddr),
        (TRT, config.media_xaddr),
    ]
    if config.ptz:
        entries.append((TPTZ, config.ptz_xaddr))
    items = "".join(
        f"<tds:Service><tds:Namespace>{namespace}</tds:Namespace><tds:XAddr>{xaddr}</tds:XAddr>"
        "<tds:Version><tt:Major>2</tt:Major><tt:Minor>0</tt:Minor></tds:Version></tds:Service>"
        for namespace, xaddr in entries
    )
    return f"<tds:GetServicesResponse>{items}</tds:GetServicesResponse>"


def profile_list(config: Config) -> list[tuple[str, str, tuple[int, int]]]:
    """List the media profiles of the camera.

    Args:
        config: Camera settings.

    Returns:
        Tuples of token, name and size.
    """
    result = [("main", "mainStream", config.main_size)]
    if config.sub_size:
        result.append(("sub", "subStream", config.sub_size))
    return result


def profiles(config: Config) -> str:
    """Build the GetProfiles answer.

    Args:
        config: Camera settings.

    Returns:
        The response body.
    """
    ptz = (
        '<tt:PTZConfiguration token="ptz"><tt:Name>ptz</tt:Name><tt:UseCount>1</tt:UseCount>'
        "<tt:NodeToken>node</tt:NodeToken></tt:PTZConfiguration>"
        if config.ptz
        else ""
    )
    items = "".join(
        f'<trt:Profiles token="{token}" fixed="true"><tt:Name>{name}</tt:Name>'
        f'<tt:VideoEncoderConfiguration token="enc-{token}"><tt:Name>enc-{token}</tt:Name>'
        "<tt:UseCount>1</tt:UseCount><tt:Encoding>H264</tt:Encoding>"
        f"<tt:Resolution><tt:Width>{width}</tt:Width><tt:Height>{height}</tt:Height></tt:Resolution>"
        f"</tt:VideoEncoderConfiguration>{ptz}</trt:Profiles>"
        for token, name, (width, height) in profile_list(config)
    )
    return f"<trt:GetProfilesResponse>{items}</trt:GetProfilesResponse>"


def stream_uri(config: Config, request: Element) -> str:
    """Build the GetStreamUri answer.

    Args:
        config: Camera settings.
        request: The GetStreamUri request element.

    Returns:
        The response body, with the main stream when the token is unknown.
    """
    token = find_text(request, "ProfileToken")
    path = "sub" if token == "sub" and config.sub_size else "main"
    return (
        "<trt:GetStreamUriResponse><trt:MediaUri>"
        f"<tt:Uri>rtsp://{config.address}:{RTSP_PORT}/{path}</tt:Uri>"
        "<tt:InvalidAfterConnect>false</tt:InvalidAfterConnect>"
        "<tt:InvalidAfterReboot>false</tt:InvalidAfterReboot>"
        "<tt:Timeout>PT0S</tt:Timeout></trt:MediaUri></trt:GetStreamUriResponse>"
    )


def handle_soap(config: Config, content: bytes) -> tuple[int, bytes]:
    """Answer one SOAP request.

    Args:
        config: Camera settings.
        content: Raw request bytes.

    Returns:
        The HTTP status and the response envelope.
    """
    try:
        root = ElementTree.fromstring(content)
    except ElementTree.ParseError:
        return fault("ter:InvalidArgVal", "The request is not valid XML")
    body = next((item for item in root if local_name(item.tag) == "Body"), None)
    request = next(iter(body), None) if body is not None else None
    if request is None:
        return fault("ter:InvalidArgVal", "The request has no body")
    action = local_name(request.tag)
    if action == "GetSystemDateAndTime":
        return 200, envelope(system_date_and_time())
    if not authorized(config, root):
        return fault("ter:NotAuthorized", "Sender not authorized")
    if action == "GetDeviceInformation":
        return 200, envelope(device_information(config))
    if action == "GetCapabilities":
        return 200, envelope(capabilities(config))
    if action == "GetServices":
        return 200, envelope(services(config))
    if action == "GetProfiles":
        return 200, envelope(profiles(config))
    if action == "GetStreamUri":
        return 200, envelope(stream_uri(config, request))
    if action == "ContinuousMove" and config.ptz:
        print(f"ptz move {find_text(request, 'ProfileToken')}", flush=True)
        return 200, envelope("<tptz:ContinuousMoveResponse/>")
    if action == "Stop" and config.ptz:
        print(f"ptz stop {find_text(request, 'ProfileToken')}", flush=True)
        return 200, envelope("<tptz:StopResponse/>")
    return fault("ter:ActionNotSupported", f"Action {action} is not supported")


def make_handler(config: Config) -> type[BaseHTTPRequestHandler]:
    """Create the HTTP request handler class for a camera.

    Args:
        config: Camera settings.

    Returns:
        A handler class that answers ONVIF POST requests.
    """

    class Handler(BaseHTTPRequestHandler):
        """Answer ONVIF SOAP requests on any path."""

        def do_POST(self) -> None:
            """Read the request body and write the SOAP answer."""
            length = int(self.headers.get("Content-Length") or 0)
            status, payload = handle_soap(config, self.rfile.read(length))
            self.send_response(status)
            self.send_header("Content-Type", CONTENT_TYPE)
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)

        def log_message(self, format: str, *args: object) -> None:
            """Log a request line to standard output.

            Args:
                format: Format string.
                *args: Format arguments.
            """
            print(f"http {self.address_string()} {format % args}", flush=True)

    return Handler


def handle_probe(config: Config, data: bytes) -> bytes | None:
    """Build the ProbeMatches answer for a WS-Discovery Probe.

    Args:
        config: Camera settings.
        data: Raw datagram.

    Returns:
        The ProbeMatches message, or None when the datagram is not a Probe this camera answers.
    """
    try:
        root = ElementTree.fromstring(data)
    except ElementTree.ParseError:
        return None
    body = next((item for item in root if local_name(item.tag) == "Body"), None)
    if body is None or find(body, "Probe") is None:
        return None
    wanted = {value.split(":")[-1] for value in find_text(body, "Types").split()}
    if wanted and not wanted & PROBE_TYPES:
        return None
    header = next((item for item in root if local_name(item.tag) == "Header"), None)
    relates = find_text(header, "MessageID")
    scopes = ["onvif://www.onvif.org/type/video_encoder"]
    if config.ptz:
        scopes.append("onvif://www.onvif.org/type/ptz")
    scopes.append(f"onvif://www.onvif.org/name/{quote(config.name)}")
    scopes.append(f"onvif://www.onvif.org/hardware/{quote(config.model)}")
    message = (
        '<?xml version="1.0" encoding="UTF-8"?>'
        f'<s:Envelope xmlns:s="{SOAP}" xmlns:wsa="{WSA}" xmlns:d="{WSD}" xmlns:dn="{DN}" xmlns:tds="{TDS}">'
        f"<s:Header><wsa:MessageID>urn:uuid:{uuid.uuid4()}</wsa:MessageID>"
        f"<wsa:RelatesTo>{escape(relates)}</wsa:RelatesTo>"
        f"<wsa:To>{ANONYMOUS}</wsa:To><wsa:Action>{PROBE_MATCHES_ACTION}</wsa:Action></s:Header>"
        "<s:Body><d:ProbeMatches><d:ProbeMatch>"
        f"<wsa:EndpointReference><wsa:Address>{config.endpoint}</wsa:Address></wsa:EndpointReference>"
        "<d:Types>dn:NetworkVideoTransmitter tds:Device</d:Types>"
        f"<d:Scopes>{escape(' '.join(scopes))}</d:Scopes>"
        f"<d:XAddrs>{config.device_xaddr}</d:XAddrs>"
        "<d:MetadataVersion>1</d:MetadataVersion>"
        "</d:ProbeMatch></d:ProbeMatches></s:Body></s:Envelope>"
    )
    return message.encode()


def serve_discovery(config: Config, sock: socket.socket) -> None:
    """Answer WS-Discovery probes received on a socket until it is closed.

    Args:
        config: Camera settings.
        sock: Bound UDP socket.
    """
    while True:
        try:
            data, sender = sock.recvfrom(65535)
        except OSError:
            return
        answer = handle_probe(config, data)
        if answer is not None:
            sock.sendto(answer, sender)
            print(f"discovery matched {sender[0]}:{sender[1]}", flush=True)


def discovery_socket(config: Config) -> socket.socket:
    """Open the multicast WS-Discovery socket.

    Args:
        config: Camera settings.

    Returns:
        A UDP socket bound to the discovery port and joined to the discovery group on the camera address.
    """
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("0.0.0.0", DISCOVERY_PORT))
    membership = struct.pack("4s4s", socket.inet_aton(DISCOVERY_GROUP), socket.inet_aton(config.address))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, membership)
    return sock


def main() -> None:
    """Run the discovery thread and the ONVIF HTTP server."""
    config = load_config(dict(os.environ))
    threading.Thread(target=serve_discovery, args=(config, discovery_socket(config)), daemon=True).start()
    server = ThreadingHTTPServer(("0.0.0.0", HTTP_PORT), make_handler(config))
    print(f"onvif responder for {config.name} at {config.address}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
