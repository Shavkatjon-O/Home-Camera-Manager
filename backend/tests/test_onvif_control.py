from datetime import UTC, datetime
from xml.etree import ElementTree

import pytest

from app.core.exceptions import Unprocessable
from app.modules.control.schemas import EncoderUpdate
from app.modules.control.services.control import CameraControlService, with_credentials, with_start
from app.onvif import analytics, imaging, media, ptz, recordings, system
from app.onvif.soap import descendant, envelope, parse_response

SCHEMA = 'xmlns:tt="http://www.onvif.org/ver10/schema"'


def body(inner: str):
    document = (
        '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" '
        f'xmlns:tr2="http://www.onvif.org/ver20/media/wsdl" {SCHEMA}><s:Body>{inner}</s:Body></s:Envelope>'
    )
    return parse_response(document.encode(), 200)


MEDIA2_ENCODERS = """<tr2:GetVideoEncoderConfigurationsResponse>
<tr2:Configurations token="VideoEncoderToken_2" GovLength="40" Profile="Main"><tt:Name>VideoEncoder_2</tt:Name>
<tt:UseCount>1</tt:UseCount><tt:Encoding>H265</tt:Encoding><tt:Resolution><tt:Width>768</tt:Width>
<tt:Height>432</tt:Height></tt:Resolution><tt:RateControl ConstantBitRate="false"><tt:FrameRateLimit>10.000000
</tt:FrameRateLimit><tt:BitrateLimit>768</tt:BitrateLimit></tt:RateControl><tt:Quality>3.000000</tt:Quality>
</tr2:Configurations></tr2:GetVideoEncoderConfigurationsResponse>"""

MEDIA2_OPTIONS = """<tr2:GetVideoEncoderConfigurationOptionsResponse>
<tr2:Options GovLengthRange="1 400" FrameRatesSupported="25 15 12 10" ProfilesSupported="Main Main10">
<tt:Encoding>H265</tt:Encoding><tt:QualityRange><tt:Min>0</tt:Min><tt:Max>5</tt:Max></tt:QualityRange>
<tt:ResolutionsAvailable><tt:Width>768</tt:Width><tt:Height>432</tt:Height></tt:ResolutionsAvailable>
<tt:ResolutionsAvailable><tt:Width>512</tt:Width><tt:Height>288</tt:Height></tt:ResolutionsAvailable>
<tt:BitrateRange><tt:Min>256</tt:Min><tt:Max>1024</tt:Max></tt:BitrateRange></tr2:Options>
</tr2:GetVideoEncoderConfigurationOptionsResponse>"""


def control() -> CameraControlService:
    return CameraControlService.__new__(CameraControlService)


def test_media2_encoder_and_options_are_parsed():
    encoder = media.parse_encoders(body(MEDIA2_ENCODERS), media.MEDIA2)[0]
    assert (encoder.encoding, encoder.width, encoder.height, encoder.fps, encoder.gop) == ("H265", 768, 432, 10.0, 40)
    option = media.parse_media2_options(body(MEDIA2_OPTIONS))[0]
    assert option.fps_values == (10.0, 12.0, 15.0, 25.0)
    assert option.resolutions == ((768, 432), (512, 288))
    assert (option.gop.minimum, option.gop.maximum) == (1, 400)
    assert option.profiles == ("Main", "Main10")


def test_media2_set_body_keeps_the_codec_and_round_trips():
    encoder = media.parse_encoders(body(MEDIA2_ENCODERS), media.MEDIA2)[0]
    request = media.set_body(media.changed(encoder, fps=12))
    parsed = ElementTree.fromstring(envelope(request))
    sent = media.parse_encoder(descendant(parsed, "Configuration"), media.MEDIA2)
    assert (sent.encoding, sent.fps, sent.gop, sent.bitrate, sent.profile) == ("H265", 12.0, 40, 768, "Main")


def test_encoder_changes_are_checked_against_the_options():
    encoder = media.parse_encoders(body(MEDIA2_ENCODERS), media.MEDIA2)[0]
    options = media.parse_media2_options(body(MEDIA2_OPTIONS))
    updated = control().validate_encoder(encoder, options, EncoderUpdate(fps=12, width=512, height=288))
    assert (updated.fps, updated.width, updated.height) == (12, 512, 288)
    with pytest.raises(Unprocessable):
        control().validate_encoder(encoder, options, EncoderUpdate(fps=13))
    with pytest.raises(Unprocessable):
        control().validate_encoder(encoder, options, EncoderUpdate(width=1920, height=1080))
    with pytest.raises(Unprocessable):
        control().validate_encoder(encoder, options, EncoderUpdate(bitrate=4096))
    with pytest.raises(Unprocessable):
        control().validate_encoder(encoder, options, EncoderUpdate(encoding="JPEG"))


def test_cell_masks_round_trip_through_packbits():
    assert analytics.cells_value(396, True) == "0P8A8A=="
    assert analytics.active_count("0P8A8A==", 396) == 396
    off = analytics.cells_value(396, False)
    assert analytics.active_count(off, 396) == 0
    raw = bytes([1, 2, 2, 2, 3, 4, 4, 5] * 20)
    assert analytics.unpack_bits(analytics.pack_bits(raw)) == raw


def test_imaging_body_sends_only_given_fields_in_schema_order():
    request = imaging.set_body(
        "VideoSource_1", imaging.ImagingState(brightness=55, ir_cut_filter="AUTO", wdr_mode="OFF")
    )
    assert request.index("Brightness") < request.index("IrCutFilter") < request.index("WideDynamicRange")
    assert "Contrast" not in request
    assert "<timg:ForcePersistence>true</timg:ForcePersistence>" in request


def test_presets_and_node_are_parsed():
    answer = body(
        '<tptz:GetPresetsResponse xmlns:tptz="http://www.onvif.org/ver20/ptz/wsdl">'
        '<tptz:Preset token="PRESET_0"><tt:Name>Door</tt:Name></tptz:Preset></tptz:GetPresetsResponse>'
    )
    assert ptz.parse_presets(answer) == [ptz.Preset(token="PRESET_0", name="Door")]
    node = body(
        '<tptz:GetNodesResponse xmlns:tptz="http://www.onvif.org/ver20/ptz/wsdl"><tptz:PTZNode token="N">'
        "<tt:MaximumNumberOfPresets>100</tt:MaximumNumberOfPresets><tt:HomeSupported>true</tt:HomeSupported>"
        "</tptz:PTZNode></tptz:GetNodesResponse>"
    )
    assert ptz.parse_node(node) == ptz.NodeInfo(max_presets=100, home_supported=True)


def at(hour: int, minute: int = 0) -> datetime:
    return datetime(2026, 11, 18, hour, minute, tzinfo=UTC)


def test_recording_segments_follow_the_track_state():
    changes = [
        recordings.TrackChange(at(0), "video", True, True),
        recordings.TrackChange(at(4, 43), "video", False, False),
        recordings.TrackChange(at(5, 1), "video", True, False),
        recordings.TrackChange(at(6), "audio", False, False),
        recordings.TrackChange(at(10, 39), "video", False, False),
        recordings.TrackChange(at(10, 56), "video", True, False),
    ]
    assert recordings.segments(changes, at(0), at(12), ("video",)) == [
        (at(0), at(4, 43)),
        (at(5, 1), at(10, 39)),
        (at(10, 56), at(12)),
    ]


def test_manual_time_keeps_the_zone_and_ntp_mode_restores():
    clock = system.Clock(mode="NTP", timezone="UTC-5", daylight_savings=False, utc=None)
    request = system.manual_time_body(clock, datetime(2026, 11, 19, 22, 27, 47, tzinfo=UTC))
    assert "<tds:DateTimeType>Manual</tds:DateTimeType>" in request
    assert "<tt:TZ>UTC-5</tt:TZ>" in request
    assert "<tt:Hour>22</tt:Hour><tt:Minute>27</tt:Minute><tt:Second>47</tt:Second>" in request
    assert "<tds:DateTimeType>NTP</tds:DateTimeType>" in system.ntp_mode_body(clock)
    ElementTree.fromstring(envelope(request))
    ElementTree.fromstring(envelope(system.REBOOT))


def test_replay_address_gets_credentials_and_start():
    uri = "rtsp://192.168.1.106:554/Streaming/Tracks/101?transportmode=unicast&replaymode=onvifreplay"
    url = with_start(with_credentials(uri, "admin", "p@ss"), datetime(2026, 11, 19, 12, tzinfo=UTC))
    assert url == (
        "rtsp://admin:p%40ss@192.168.1.106:554/Streaming/Tracks/101"
        "?transportmode=unicast&replaymode=onvifreplay&starttime=20261119T120000Z"
    )
