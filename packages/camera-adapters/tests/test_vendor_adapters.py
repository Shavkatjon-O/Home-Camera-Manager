import pytest

from camera_adapters.base import AdapterError, Fingerprint, Identity, Target
from camera_adapters.ezviz.adapter import EzvizAdapter
from camera_adapters.ezviz.quirks import corrected_sensitivity
from camera_adapters.v380 import adapter as v380_module
from camera_adapters.v380.adapter import V380Adapter


def test_ezviz_sensitivity_is_written_once_more_by_the_offset():
    assert corrected_sensitivity(60, 80) == 40
    assert corrected_sensitivity(60, 60) is None
    assert corrected_sensitivity(10, 40) is None
    assert corrected_sensitivity(60, None) is None


async def test_ezviz_streams_default_to_its_fixed_paths():
    streams = await EzvizAdapter().streams(Target(host="192.168.1.20"))
    assert (streams.main, streams.sub) == ("/Streaming/Channels/101", "/Streaming/Channels/102")


def test_an_ezviz_camera_always_has_a_sub_stream():
    manifest = EzvizAdapter().manifest()
    assert manifest.adapter == "ezviz" and manifest.media.sub


async def test_ezviz_identifies_through_onvif(onvif_device):
    onvif_device("simulated")
    identity = await EzvizAdapter().identify(Target(host="192.168.1.20", port=80))
    assert identity.adapter == "ezviz" and identity.manifest.adapter == "ezviz" and identity.manifest.media.sub


async def test_a_v380_camera_without_a_bridge_asks_for_one(monkeypatch):
    async def port_open(host, port, timeout=0):
        return port == 8800

    monkeypatch.setattr(v380_module, "port_open", port_open)
    with pytest.raises(AdapterError) as caught:
        await V380Adapter().identify(Target(host="192.168.1.40", timeout=0.1))
    assert caught.value.code == "unsupported"


async def test_a_v380_camera_is_identified_through_its_bridge(monkeypatch):
    async def port_open(host, port, timeout=0):
        return port == 8554

    class Bridge:
        def __init__(self, host):
            pass

        async def available(self):
            return True

    async def no_onvif(self, target):
        raise AdapterError("unreachable", "no")

    monkeypatch.setattr(v380_module, "port_open", port_open)
    monkeypatch.setattr(v380_module, "BridgeClient", Bridge)
    monkeypatch.setattr(v380_module.OnvifAdapter, "identify", no_onvif)
    identity = await V380Adapter().identify(Target(host="v380-bridge-1", timeout=0.1))
    assert isinstance(identity, Identity) and identity.channels[0].main_path == "/live"
    assert identity.manifest.control.light and identity.manifest.control.siren


def test_the_v380_port_wins():
    assert V380Adapter().match(Fingerprint(host="h", open_ports=(8800,), v380=True)) == 70
    assert V380Adapter().match(Fingerprint(host="h", open_ports=(554,))) == 0
