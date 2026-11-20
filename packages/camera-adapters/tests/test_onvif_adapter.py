import pytest

from camera_adapters.base import AdapterError, DeviceKind, Fingerprint, Target
from camera_adapters.onvif.adapter import OnvifAdapter, group_channels, normalise_topic
from camera_adapters.onvif.client import Profile


async def test_a_camera_is_identified_with_its_streams_and_ptz(onvif_device):
    onvif_device("simulated")
    identity = await OnvifAdapter().identify(Target(host="192.168.1.20", port=80))
    assert identity.vendor == "Simulated" and identity.model == "SIM-1"
    assert identity.kind == DeviceKind.CAMERA
    assert [(channel.main_path, channel.sub_path) for channel in identity.channels] == [("/main", "/sub")]
    assert identity.manifest.control.ptz and identity.manifest.media.sub
    assert identity.manifest.media.codecs == ("h264",)


async def test_a_recorder_has_one_channel_per_video_source(onvif_device):
    onvif_device("recorder")
    identity = await OnvifAdapter().identify(Target(host="192.168.1.30", port=80))
    assert identity.kind == DeviceKind.NVR
    assert [(channel.index, channel.token, channel.main_path, channel.sub_path) for channel in identity.channels] == [
        (1, "VideoSource_1", "/Streaming/Channels/101", "/Streaming/Channels/102"),
        (2, "VideoSource_2", "/Streaming/Channels/201", "/Streaming/Channels/202"),
    ]
    assert identity.manifest.channels == 2 and identity.manifest.media.codecs == ("h265",)
    assert not identity.manifest.control.ptz


async def test_a_refused_login_is_unauthorized(onvif_device):
    onvif_device("simulated", refuse=True)
    with pytest.raises(AdapterError) as caught:
        await OnvifAdapter().identify(Target(host="192.168.1.20", port=80, username="admin", password="wrong"))
    assert caught.value.code == "unauthorized"


async def test_streams_of_a_channel_come_from_its_source(onvif_device):
    onvif_device("recorder")
    streams = await OnvifAdapter().streams(Target(host="192.168.1.30", port=80), channel=2)
    assert (streams.main, streams.sub, streams.rtsp_port) == ("/Streaming/Channels/201", "/Streaming/Channels/202", 554)
    with pytest.raises(AdapterError):
        await OnvifAdapter().streams(Target(host="192.168.1.30", port=80), channel=3)


def test_profiles_without_a_source_form_one_channel():
    profiles = [
        Profile("a", "A", "H264", 1920, 1080, False, "rtsp://h/a"),
        Profile("b", "B", "H264", 640, 360, False, "rtsp://h/b"),
    ]
    channels = group_channels(profiles)
    assert len(channels) == 1 and channels[0].main_path == "/a" and channels[0].sub_path == "/b"


def test_topics_are_normalised():
    assert normalise_topic("tns1:VideoSource/MotionAlarm") == "motion"
    assert normalise_topic("tns1:VideoSource/ImageTooBlurry/AnalyticsService") == "tamper"
    assert normalise_topic("tns1:Device/HardwareFailure/StorageFailure") == "storage"
    assert normalise_topic("tns1:Monitoring/OperatingTime/LastReboot") == "reboot"
    assert normalise_topic("tns1:RuleEngine/LineDetector/Crossed") is None


def test_an_onvif_service_address_label_is_read():
    label = OnvifAdapter().parse_label("http://192.168.1.20:8899/onvif/device_service")
    assert label.confirmed and (label.host, label.port) == ("192.168.1.20", 8899)
    assert OnvifAdapter().parse_label("http://192.168.1.20/index.html") is None


def test_an_onvif_device_matches_above_a_web_host():
    adapter = OnvifAdapter()
    assert adapter.match(Fingerprint(host="h", onvif_port=80)) > adapter.match(Fingerprint(host="h", open_ports=(80,)))
    assert adapter.match(Fingerprint(host="h", open_ports=(554,))) == 0
