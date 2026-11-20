from datetime import UTC, datetime
from types import SimpleNamespace
from uuid import uuid4

import pytest

from app.core.exceptions import Unprocessable
from app.modules.devices.schemas.pairing import PairingMethodId
from app.modules.devices.services import pairing_catalog
from app.modules.devices.services.pairing_catalog import PairingCatalogService

PROVISIONING = {"wifi_qr", "soft_ap", "ble", "sound_wave", "matter"}


class Session:
    def __init__(self, connectors=()):
        self.connectors = list(connectors)

    async def scalars(self, statement):
        return self.connectors

    async def scalar(self, statement):
        return None


def connector(seen=True):
    return SimpleNamespace(uuid=uuid4(), last_seen_at=datetime.now(UTC) if seen else None)


@pytest.fixture
def direct(monkeypatch):
    def set_direct(value):
        monkeypatch.setattr(pairing_catalog, "settings", SimpleNamespace(direct_cameras=value))

    return set_direct


def ids(listing):
    return [item.id for item in listing.items]


async def test_without_a_connector_pairing_one_comes_first(direct):
    direct(True)
    listing = await PairingCatalogService(Session(), is_admin=True).methods()
    assert ids(listing)[0] == PairingMethodId.CONNECTOR_QR and listing.items[0].recommended
    assert PairingMethodId.CONNECTOR_DISCOVERY not in ids(listing)
    manual = next(item for item in listing.items if item.id == PairingMethodId.MANUAL_HOST)
    assert "direct" in manual.requires


async def test_adding_by_address_needs_a_connector_when_direct_mode_is_off(direct):
    direct(False)
    listing = await PairingCatalogService(Session(), is_admin=True).methods()
    assert PairingMethodId.MANUAL_HOST not in ids(listing) and PairingMethodId.NVR_IMPORT not in ids(listing)
    online = await PairingCatalogService(Session([connector()]), is_admin=True).methods()
    assert ids(online)[0] == PairingMethodId.CONNECTOR_DISCOVERY
    assert "connector" in next(item for item in online.items if item.id == PairingMethodId.MANUAL_HOST).requires


async def test_an_offline_connector_offers_no_discovery(direct):
    direct(False)
    listing = await PairingCatalogService(Session([connector(seen=False)]), is_admin=True).methods()
    assert PairingMethodId.CONNECTOR_DISCOVERY not in ids(listing) and listing.connectors == []


async def test_viewers_get_no_method(direct):
    direct(True)
    assert (await PairingCatalogService(Session(), is_admin=False).methods()).items == []


async def test_a_scanned_stream_address_leads_to_the_stream_method(direct):
    direct(True)
    listing = await PairingCatalogService(Session(), is_admin=True).methods(label="rtsp://192.168.1.20/live")
    first = listing.items[0]
    assert first.id == PairingMethodId.RTSP_URL and first.recommended
    assert next(item for item in first.parameters if item.name == "rtsp_url").prefill == "rtsp://192.168.1.20:554/live"


async def test_no_provisioning_method_is_offered(direct):
    direct(True)
    listing = await PairingCatalogService(Session([connector()]), is_admin=True).methods()
    assert not PROVISIONING.intersection(str(item) for item in ids(listing))


def test_labels_are_read_or_refused():
    service = PairingCatalogService(Session(), is_admin=True)
    label = service.label("CS-C6N-A0-1C2WFR\nE12345678\nABCDEF")
    assert label.adapter == "ezviz" and not label.confirmed and label.code == "ABCDEF"
    assert label.methods[0] == PairingMethodId.CONNECTOR_DISCOVERY
    with pytest.raises(Unprocessable):
        service.label("not a label")
