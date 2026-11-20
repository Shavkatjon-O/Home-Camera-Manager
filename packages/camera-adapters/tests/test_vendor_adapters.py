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


async def test_a_v380_camera_without_its_device_id_asks_for_it(monkeypatch):
    async def port_open(host, port, timeout=0):
        return port == 8800

    monkeypatch.setattr(v380_module, "port_open", port_open)
    with pytest.raises(AdapterError) as caught:
        await V380Adapter().identify(Target(host="192.168.1.40", timeout=0.1))
    assert caught.value.code == "invalid"


async def test_a_v380_camera_is_identified_through_its_relay(monkeypatch):
    async def port_open(host, port, timeout=0):
        return port == 8554

    async def relay_status(self, host, timeout):
        return {"status": "running", "streams": {"main": {"codec": "h265", "width": 2304, "height": 2592}}}

    monkeypatch.setattr(v380_module, "port_open", port_open)
    monkeypatch.setattr(V380Adapter, "relay_status", relay_status)
    identity = await V380Adapter().identify(Target(host="v380-relay-1", timeout=0.1))
    assert isinstance(identity, Identity)
    channel = identity.channels[0]
    assert (channel.main_path, channel.sub_path, channel.width, channel.height) == ("/main", "/sub", 2304, 2592)
    assert identity.rtsp_port == 8554
    control = identity.manifest.control
    assert control.ptz and control.light and control.siren and not control.presets and not control.home


async def test_a_stream_server_without_the_relay_api_is_not_a_relay(monkeypatch):
    async def port_open(host, port, timeout=0):
        return port == 8554

    async def relay_status(self, host, timeout):
        return {"status": "running"}

    monkeypatch.setattr(v380_module, "port_open", port_open)
    monkeypatch.setattr(V380Adapter, "relay_status", relay_status)
    with pytest.raises(AdapterError) as caught:
        await V380Adapter().identify(Target(host="v380-ptz-1", timeout=0.1))
    assert caught.value.code == "unsupported"


def test_a_hand_registered_v380_camera_keeps_its_earlier_manifest():
    manifest = V380Adapter().manifest(ptz=True, sub=False)
    assert manifest.control.presets and manifest.control.home and manifest.control.light
    assert not manifest.media.sub and manifest.media.codecs == ("h265",)
    native = V380Adapter().manifest(ptz=True, sub=True, bridged=False)
    assert native.control.ptz and not native.control.presets and not native.control.zoom and native.media.sub


@pytest.mark.parametrize(
    ("pan", "tilt", "move"),
    [(0, 0, "stop"), (-0.5, 0.2, "left"), (0.3, 0, "right"), (0.1, 0.9, "up"), (0, -1, "down"), (0.5, -0.5, "right")],
)
def test_v380_moves_follow_the_stronger_axis(pan, tilt, move):
    assert v380_module.axis_move(pan, tilt) == move


async def test_a_v380_zoom_alone_is_unsupported():
    with pytest.raises(AdapterError) as caught:
        await V380Adapter().move(Target(host="h", device_id="12345678"), 1, 0, 0, 0.5)
    assert caught.value.code == "unsupported"


def test_the_v380_port_wins():
    assert V380Adapter().match(Fingerprint(host="h", open_ports=(8800,), v380=True)) == 70
    assert V380Adapter().match(Fingerprint(host="h", open_ports=(554,))) == 0
