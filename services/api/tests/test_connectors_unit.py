from datetime import UTC, datetime, timedelta
from uuid import uuid4

import httpx
import pytest
from pydantic import ValidationError

from app.core.exceptions import BadGateway, Conflict
from app.core.security import encrypt_secret
from app.models import Connector, ConnectorPairing
from app.modules.devices.agent import AgentClient, agent_address
from app.modules.devices.enums import CameraBrand, ConnectorPairingStatus
from app.modules.devices.schemas import ConnectorCameraConfig
from app.modules.devices.schemas.connectors import ConnectorClaim, clean_user_code
from app.modules.devices.services.connector_device import config_version
from app.modules.devices.services.connector_pairing import (
    CODE_ALPHABET,
    format_user_code,
    new_user_code,
    pairing_status,
)

NOW = datetime(2026, 11, 20, 12, 0, tzinfo=UTC)


@pytest.mark.parametrize(
    "value",
    ["BCDF-GHJK", "bcdfghjk", "  bcdf ghjk ", "https://x.example/connect?code=BCDF-GHJK", "/c?code=BCDFGHJK&x=1"],
)
def test_clean_user_code_accepts_typed_and_scanned_forms(value):
    assert clean_user_code(value) == "BCDFGHJK"


@pytest.mark.parametrize("value", ["BCDF", "BCDF-GHJ", "BCDF-GHJKL", "", "https://x.example/connect?code=BCD"])
def test_clean_user_code_refuses_a_wrong_length(value):
    with pytest.raises(ValueError):
        clean_user_code(value)


def test_claim_normalises_the_code_and_refuses_a_short_one():
    assert ConnectorClaim(user_code="bcdf-ghjk").user_code == "BCDFGHJK"
    with pytest.raises(ValidationError):
        ConnectorClaim(user_code="bcdf")


def test_new_user_code_uses_only_the_alphabet_and_has_eight_letters():
    for _ in range(50):
        code = new_user_code()
        assert len(code) == 8
        assert set(code) <= set(CODE_ALPHABET)


def test_format_user_code_puts_a_hyphen_in_the_middle():
    assert format_user_code("BCDFGHJK") == "BCDF-GHJK"


def pairing(**fields):
    base = {"expires_at": NOW + timedelta(minutes=5), "claimed_at": None, "delivered_at": None}
    base.update(fields)
    return ConnectorPairing(**base)


def test_pairing_pending():
    assert pairing_status(pairing(), NOW) == ConnectorPairingStatus.PENDING


def test_pairing_claimed():
    assert pairing_status(pairing(claimed_at=NOW), NOW) == ConnectorPairingStatus.CLAIMED


def test_pairing_expired():
    assert pairing_status(pairing(expires_at=NOW), NOW) == ConnectorPairingStatus.EXPIRED


def test_pairing_delivered_wins_over_expiry():
    found = pairing(delivered_at=NOW, expires_at=NOW - timedelta(minutes=1))
    assert pairing_status(found, NOW) == ConnectorPairingStatus.DELIVERED


def connector(**fields):
    base = {
        "uuid": uuid4(),
        "mode": "direct",
        "address": "10.0.0.5",
        "tunnel_address": "100.64.0.9",
        "api_port": 8780,
        "agent_key_encrypted": encrypt_secret("key"),
    }
    base.update(fields)
    return Connector(**base)


def test_agent_address_in_direct_mode():
    assert agent_address(connector()) == "10.0.0.5"


def test_agent_address_in_tunnel_mode():
    assert agent_address(connector(mode="tunnel")) == "100.64.0.9"


def test_agent_address_is_none_before_the_connector_reports_one():
    assert agent_address(connector(address=None)) is None


async def test_agent_client_sends_the_bearer_key_to_the_api_path():
    seen = []

    def handler(request: httpx.Request) -> httpx.Response:
        seen.append(request)
        return httpx.Response(200, json={"ok": True})

    client = AgentClient(connector(), httpx.MockTransport(handler))
    assert await client.call("POST", "/discovery") == {"ok": True}
    request = seen[0]
    assert str(request.url) == "http://10.0.0.5:8780/api/discovery"
    assert request.method == "POST"
    assert request.headers["Authorization"] == "Bearer key"


async def test_agent_client_uses_the_tunnel_address():
    seen = []

    def handler(request: httpx.Request) -> httpx.Response:
        seen.append(str(request.url))
        return httpx.Response(204)

    client = AgentClient(connector(mode="tunnel"), httpx.MockTransport(handler))
    assert await client.call("GET", "/x") == {}
    assert seen == ["http://100.64.0.9:8780/api/x"]


async def test_agent_client_turns_a_refusal_into_bad_gateway():
    client = AgentClient(connector(), httpx.MockTransport(lambda request: httpx.Response(403, text="no")))
    with pytest.raises(BadGateway) as caught:
        await client.call("GET", "/x")
    assert caught.value.code == "connector_refused"


async def test_agent_client_turns_a_network_error_into_bad_gateway():
    def handler(request):
        raise httpx.ConnectError("down")

    client = AgentClient(connector(), httpx.MockTransport(handler))
    with pytest.raises(BadGateway) as caught:
        await client.call("GET", "/x")
    assert caught.value.code == "connector_unreachable"


async def test_agent_client_without_an_address_conflicts():
    client = AgentClient(connector(address=None), httpx.MockTransport(lambda request: httpx.Response(200)))
    with pytest.raises(Conflict) as caught:
        await client.call("GET", "/x")
    assert caught.value.code == "connector_offline"


def camera_config(**fields):
    base = {
        "uuid": uuid4(),
        "name": "Door",
        "brand": CameraBrand.RTSP,
        "host": "10.0.0.7",
        "rtsp_port": 554,
        "onvif_port": None,
        "main_path": "/main",
        "sub_path": "/sub",
        "enabled": True,
    }
    base.update(fields)
    return ConnectorCameraConfig(**base)


def test_config_version_is_stable_for_the_same_cameras():
    one = camera_config()
    assert config_version([one]) == config_version([one.model_copy()])
    assert len(config_version([one])) == 16


def test_config_version_changes_when_a_camera_changes():
    one = camera_config()
    assert config_version([one]) != config_version([one.model_copy(update={"enabled": False})])
    assert config_version([one]) != config_version([])
