import re
from functools import partial
from pathlib import Path

import httpx
import pytest

from camera_adapters.onvif import client as client_module

FIXTURES = Path(__file__).parent / "fixtures"
FAULT = (
    '<?xml version="1.0" encoding="UTF-8"?><s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" '
    'xmlns:ter="http://www.onvif.org/ver10/error"><s:Body><s:Fault><s:Code><s:Value>s:Sender</s:Value>'
    "<s:Subcode><s:Value>ter:{code}</s:Value></s:Subcode></s:Code><s:Reason><s:Text>{code}</s:Text></s:Reason>"
    "</s:Fault></s:Body></s:Envelope>"
)


def operation(content: bytes) -> str:
    found = re.search(rb"Body>\s*<(?:\w+:)?(\w+)", content)
    name = found.group(1).decode() if found else ""
    if name == "GetStreamUri":
        name += "_" + re.search(rb"ProfileToken>([^<]+)<", content).group(1).decode()
    return name


def fixture_handler(folder: str, refuse: bool = False):
    def handle(request: httpx.Request) -> httpx.Response:
        if refuse:
            return httpx.Response(400, text=FAULT.format(code="NotAuthorized"))
        path = FIXTURES / folder / f"{operation(request.content)}.xml"
        if not path.is_file():
            return httpx.Response(400, text=FAULT.format(code="ActionNotSupported"))
        return httpx.Response(200, content=path.read_bytes(), headers={"Content-Type": "application/soap+xml"})

    return handle


@pytest.fixture
def onvif_device(monkeypatch):
    def install(folder: str, refuse: bool = False):
        real = httpx.AsyncClient
        monkeypatch.setattr(
            client_module.httpx,
            "AsyncClient",
            partial(real, transport=httpx.MockTransport(fixture_handler(folder, refuse))),
        )

    return install
