import pytest

from camera_adapters.base import (
    Adapter,
    ControlCapability,
    EventsCapability,
    Fingerprint,
    MaintenanceCapability,
    Target,
)
from camera_adapters.manifest import CapabilityManifest
from camera_adapters.registry import default_registry

ADAPTERS = list(default_registry().adapters.values())
GARBAGE = ("", "   ", "hello world", "WIFI:S:home;T:WPA;P:secret;;", "\x00\x01")


@pytest.fixture(params=ADAPTERS, ids=lambda adapter: adapter.name)
def adapter(request):
    return request.param


def test_it_is_named_and_ranked(adapter):
    assert isinstance(adapter, Adapter)
    assert adapter.name and adapter.name == adapter.name.lower()
    assert isinstance(adapter.priority, int) and adapter.title


def test_it_scores_any_fingerprint_without_failing(adapter):
    for fingerprint in (Fingerprint(host="h"), Fingerprint(host="h", open_ports=(80, 554, 8000, 8800), v380=True)):
        score = adapter.match(fingerprint, None)
        assert isinstance(score, int) and score >= 0


def test_its_manifest_names_it_and_round_trips(adapter):
    manifest = adapter.manifest(None, ptz=True, sub=True)
    assert manifest.adapter == adapter.name
    assert CapabilityManifest.from_dict(manifest.to_dict()) == manifest


def test_its_manifest_promises_only_what_it_implements(adapter):
    manifest = adapter.manifest(None, ptz=True, sub=True)
    control = manifest.control
    if control.ptz or control.light or control.siren:
        assert isinstance(adapter, ControlCapability)
    if manifest.events.kinds:
        assert isinstance(adapter, EventsCapability)
    if manifest.maintenance.time or manifest.maintenance.reboot:
        assert isinstance(adapter, MaintenanceCapability)
    assert manifest.provisioning.methods == ()


def test_its_label_parser_ignores_garbage(adapter):
    for text in GARBAGE:
        assert adapter.parse_label(text) is None


async def test_it_keeps_known_stream_paths(adapter):
    streams = await adapter.streams(
        Target(host="192.168.1.20", main_path="/known", sub_path="/known-sub", rtsp_port=554)
    )
    assert streams.main == "/known"
