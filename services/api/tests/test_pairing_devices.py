from types import SimpleNamespace

import pytest

from app.core.exceptions import Unprocessable
from app.modules.devices.services.pairing_devices import (
    DevicePairingService,
    channel_manifest,
    identity_from_agent,
    identity_result,
)
from camera_adapters.base import Channel, DeviceKind, Identity
from camera_adapters.manifest import CapabilityManifest, ControlManifest, MediaManifest

RECORDER = Identity(
    adapter="onvif",
    kind=DeviceKind.NVR,
    channels=(
        Channel(index=1, name="One", main_path="/101", sub_path="/102", ptz=True),
        Channel(index=2, name="Two", main_path="/201"),
    ),
    manifest=CapabilityManifest(
        adapter="onvif", channels=2, media=MediaManifest(sub=True), control=ControlManifest(ptz=True, presets=True)
    ),
)


def service():
    return DevicePairingService(SimpleNamespace(), SimpleNamespace(id=1), site_id=1, registry=SimpleNamespace())


def test_a_recorder_needs_its_channels_picked():
    with pytest.raises(Unprocessable):
        service().chosen_channels(RECORDER, None)
    with pytest.raises(Unprocessable):
        service().chosen_channels(RECORDER, [3])
    assert [channel.index for channel in service().chosen_channels(RECORDER, [2, 1, 2])] == [2, 1]


def test_a_camera_adds_its_only_channel_by_default():
    camera = Identity(adapter="onvif", channels=(Channel(index=1, name="Cam", main_path="/main"),))
    assert len(service().chosen_channels(camera, None)) == 1


def test_a_channel_manifest_keeps_only_what_the_channel_has():
    moving = channel_manifest(RECORDER, RECORDER.channels[0])
    fixed = channel_manifest(RECORDER, RECORDER.channels[1])
    assert moving.control.ptz and moving.media.sub
    assert not fixed.control.ptz and not fixed.control.presets and not fixed.media.sub


def test_an_agent_identity_round_trips_without_the_serial():
    data = {
        "adapter": "onvif",
        "kind": "nvr",
        "vendor": "Simulated",
        "serial": "SIM-0002",
        "rtsp_port": 554,
        "channels": [{"index": 1, "name": "One", "main_path": "/101", "ptz": True}],
        "manifest": RECORDER.manifest.to_dict(),
    }
    identity = identity_from_agent(data)
    assert identity.kind == DeviceKind.NVR and identity.channels[0].ptz and identity.serial is None
    result = identity_result(identity, attempt=__import__("uuid").uuid4())
    assert result.capabilities.control.ptz and "serial" not in result.model_dump()
