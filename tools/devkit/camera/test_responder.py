import base64
import hashlib
import socket
import threading
import urllib.error
import urllib.request
from http.server import ThreadingHTTPServer
from xml.etree import ElementTree

import pytest
import responder

NS = (
    'xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:tds="http://www.onvif.org/ver10/device/wsdl" '
    'xmlns:trt="http://www.onvif.org/ver10/media/wsdl" xmlns:tptz="http://www.onvif.org/ver20/ptz/wsdl" '
    'xmlns:tt="http://www.onvif.org/ver10/schema"'
)


def make_config(**overrides):
    values = {
        "name": "Front Door",
        "manufacturer": "Simulated",
        "model": "SIM-1",
        "serial": "SN1",
        "address": "172.31.250.11",
        "username": "admin",
        "password": "",
        "ptz": False,
        "main_size": (1280, 720),
        "sub_size": (640, 360),
    }
    return responder.Config(**(values | overrides))


def security(password, username="admin"):
    nonce = b"0123456789abcdef"
    created = "2026-01-01T00:00:00Z"
    digest = base64.b64encode(hashlib.sha1(nonce + created.encode() + password.encode()).digest()).decode()
    return (
        '<s:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-'
        'secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
        f"<wsse:UsernameToken><wsse:Username>{username}</wsse:Username><wsse:Password>{digest}</wsse:Password>"
        f"<wsse:Nonce>{base64.b64encode(nonce).decode()}</wsse:Nonce><wsu:Created>{created}</wsu:Created>"
        "</wsse:UsernameToken></wsse:Security></s:Header>"
    )


def request(body, header=""):
    return f"<s:Envelope {NS}>{header}<s:Body>{body}</s:Body></s:Envelope>".encode()


@pytest.fixture
def serve():
    servers = []

    def start(config):
        server = ThreadingHTTPServer(("127.0.0.1", 0), responder.make_handler(config))
        threading.Thread(target=server.serve_forever, daemon=True).start()
        servers.append(server)
        return f"http://127.0.0.1:{server.server_address[1]}"

    yield start
    for server in servers:
        server.shutdown()
        server.server_close()


def post(url, payload):
    http_request = urllib.request.Request(url, data=payload, headers={"Content-Type": "application/soap+xml"})
    try:
        with urllib.request.urlopen(http_request, timeout=5) as response:
            return response.status, response.headers["Content-Type"], ElementTree.fromstring(response.read())
    except urllib.error.HTTPError as error:
        return error.code, error.headers["Content-Type"], ElementTree.fromstring(error.read())


def texts(root, name):
    return [item.text for item in root.iter() if responder.local_name(item.tag) == name]


def test_device_time_needs_no_credentials(serve):
    url = serve(make_config(password="secret"))
    status, content_type, root = post(url + "/onvif/device_service", request("<tds:GetSystemDateAndTime/>"))
    assert status == 200
    assert content_type == "application/soap+xml; charset=utf-8"
    assert texts(root, "Year")


def test_refused_without_credentials(serve):
    url = serve(make_config(password="secret"))
    status, _, root = post(url, request("<tds:GetDeviceInformation/>"))
    assert status == 400
    assert "ter:NotAuthorized" in texts(root, "Value")


def test_refused_with_wrong_digest(serve):
    url = serve(make_config(password="secret"))
    status, _, _ = post(url, request("<tds:GetDeviceInformation/>", security("other")))
    assert status == 400


def test_accepted_with_correct_digest(serve):
    url = serve(make_config(password="secret"))
    status, _, root = post(url, request("<tds:GetDeviceInformation/>", security("secret")))
    assert status == 200
    assert texts(root, "SerialNumber") == ["SN1"]
    assert texts(root, "Manufacturer") == ["Simulated"]


def test_profiles_and_stream_uris(serve):
    url = serve(make_config())
    _, _, root = post(url + "/onvif/media_service", request("<trt:GetProfiles/>"))
    profiles = [item for item in root.iter() if responder.local_name(item.tag) == "Profiles"]
    assert [item.get("token") for item in profiles] == ["main", "sub"]
    assert texts(root, "Width") == ["1280", "640"]
    assert set(texts(root, "Encoding")) == {"H264"}
    _, _, sub = post(url, request("<trt:GetStreamUri><trt:ProfileToken>sub</trt:ProfileToken></trt:GetStreamUri>"))
    assert texts(sub, "Uri") == ["rtsp://172.31.250.11:554/sub"]
    _, _, main = post(url, request("<trt:GetStreamUri><trt:ProfileToken>main</trt:ProfileToken></trt:GetStreamUri>"))
    assert texts(main, "Uri") == ["rtsp://172.31.250.11:554/main"]


def test_single_profile_without_sub_size(serve):
    url = serve(make_config(sub_size=None))
    _, _, root = post(url, request("<trt:GetProfiles/>"))
    assert [item.get("token") for item in root.iter() if responder.local_name(item.tag) == "Profiles"] == ["main"]


def test_ptz_in_capabilities_services_and_profiles(serve):
    with_ptz = serve(make_config(ptz=True))
    without = serve(make_config(ptz=False))
    body = "<tds:GetCapabilities><tds:Category>All</tds:Category></tds:GetCapabilities>"
    _, _, root = post(with_ptz, request(body))
    assert texts(root, "XAddr") == [
        "http://172.31.250.11:80/onvif/device_service",
        "http://172.31.250.11:80/onvif/media_service",
        "http://172.31.250.11:80/onvif/ptz_service",
    ]
    _, _, root = post(without, request(body))
    assert len(texts(root, "XAddr")) == 2
    _, _, root = post(with_ptz, request("<tds:GetServices/>"))
    assert "http://www.onvif.org/ver20/ptz/wsdl" in texts(root, "Namespace")
    _, _, root = post(with_ptz, request("<trt:GetProfiles/>"))
    assert len(texts(root, "NodeToken")) == 2
    status, _, _ = post(
        with_ptz, request("<tptz:ContinuousMove><tptz:ProfileToken>main</tptz:ProfileToken></tptz:ContinuousMove>")
    )
    assert status == 200
    status, _, _ = post(with_ptz, request("<tptz:Stop><tptz:ProfileToken>main</tptz:ProfileToken></tptz:Stop>"))
    assert status == 200


def test_unknown_action_faults(serve):
    url = serve(make_config())
    status, _, root = post(url, request("<tds:Reboot/>"))
    assert status == 400
    assert "ter:ActionNotSupported" in texts(root, "Value")


def probe(types):
    return (
        '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" '
        'xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" '
        'xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:dn="http://www.onvif.org/ver10/network/wsdl">'
        "<s:Header><a:MessageID>urn:uuid:probe-1</a:MessageID></s:Header>"
        f"<s:Body><d:Probe><d:Types>{types}</d:Types></d:Probe></s:Body></s:Envelope>"
    ).encode()


def test_probe_matches_over_udp():
    config = make_config(ptz=True)
    server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server.bind(("127.0.0.1", 0))
    threading.Thread(target=responder.serve_discovery, args=(config, server), daemon=True).start()
    client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client.settimeout(5)
    client.sendto(probe("dn:NetworkVideoTransmitter"), server.getsockname())
    data, _ = client.recvfrom(65535)
    client.close()
    server.close()
    root = ElementTree.fromstring(data)
    assert texts(root, "RelatesTo") == ["urn:uuid:probe-1"]
    assert texts(root, "XAddrs") == ["http://172.31.250.11:80/onvif/device_service"]
    assert texts(root, "Types") == ["dn:NetworkVideoTransmitter tds:Device"]
    scopes = texts(root, "Scopes")[0]
    assert "onvif://www.onvif.org/name/Front%20Door" in scopes
    assert "onvif://www.onvif.org/type/ptz" in scopes
    assert texts(root, "Action") == ["http://schemas.xmlsoap.org/ws/2005/04/discovery/ProbeMatches"]


def test_probe_with_empty_types_matches_and_other_types_do_not():
    config = make_config()
    assert responder.handle_probe(config, probe("")) is not None
    assert responder.handle_probe(config, probe("dn:Printer")) is None
    assert responder.handle_probe(config, b"garbage") is None
