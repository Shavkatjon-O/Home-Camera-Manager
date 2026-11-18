from xml.etree import ElementTree

import pytest

from app.onvif.client import Profile, parse_device_time, parse_profiles, pick_streams, uri_path
from app.onvif.soap import OnvifError, OnvifFault, parse_response

PROFILES_RESPONSE = b"""<?xml version="1.0" encoding="UTF-8"?>
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:trt="http://www.onvif.org/ver10/media/wsdl"
 xmlns:tt="http://www.onvif.org/ver10/schema"><s:Body><trt:GetProfilesResponse>
<trt:Profiles fixed="true" token="PROFILE_000"><tt:Name>PROFILE_000</tt:Name>
<tt:VideoEncoderConfiguration token="V_ENC_000"><tt:Encoding>H264</tt:Encoding>
<tt:Resolution><tt:Width>2304</tt:Width><tt:Height>2592</tt:Height></tt:Resolution></tt:VideoEncoderConfiguration>
<tt:PTZConfiguration token="PTZCFG_000"><tt:Name>PTZCFG_000</tt:Name></tt:PTZConfiguration></trt:Profiles>
<trt:Profiles fixed="true" token="PROFILE_001"><tt:Name>PROFILE_001</tt:Name>
<tt:VideoEncoderConfiguration token="V_ENC_001"><tt:Encoding>H264</tt:Encoding>
<tt:Resolution><tt:Width>640</tt:Width><tt:Height>720</tt:Height></tt:Resolution></tt:VideoEncoderConfiguration>
</trt:Profiles></trt:GetProfilesResponse></s:Body></s:Envelope>"""

TIME_RESPONSE = b"""<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:tt="http://www.onvif.org/ver10/schema"
 xmlns:tds="http://www.onvif.org/ver10/device/wsdl"><s:Body><tds:GetSystemDateAndTimeResponse><tds:SystemDateAndTime>
<tt:UTCDateTime><tt:Time><tt:Hour>17</tt:Hour><tt:Minute>6</tt:Minute><tt:Second>41</tt:Second></tt:Time>
<tt:Date><tt:Year>2026</tt:Year><tt:Month>11</tt:Month><tt:Day>18</tt:Day></tt:Date></tt:UTCDateTime>
</tds:SystemDateAndTime></tds:GetSystemDateAndTimeResponse></s:Body></s:Envelope>"""

FAULT_RESPONSE = b"""<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"><s:Body><s:Fault>
<s:Code><s:Value>s:Sender</s:Value><s:Subcode><s:Value>ter:NotAuthorized</s:Value></s:Subcode></s:Code>
<s:Reason><s:Text xml:lang="en">Sender not Authorized</s:Text></s:Reason></s:Fault></s:Body></s:Envelope>"""


def test_profiles_are_parsed_with_ptz_and_resolution():
    profiles = parse_profiles(parse_response(PROFILES_RESPONSE, 200))
    assert [profile.token for profile in profiles] == ["PROFILE_000", "PROFILE_001"]
    assert profiles[0].ptz is True
    assert profiles[1].ptz is False
    assert (profiles[0].width, profiles[0].height, profiles[0].encoding) == (2304, 2592, "H264")


def test_device_time_is_parsed_as_utc():
    moment = parse_device_time(parse_response(TIME_RESPONSE, 200))
    assert moment is not None
    assert moment.isoformat() == "2026-11-18T17:06:41+00:00"


def test_fault_raises_with_the_reason():
    with pytest.raises(OnvifFault, match="Sender not Authorized"):
        parse_response(FAULT_RESPONSE, 400)


def test_non_soap_answer_raises():
    with pytest.raises(OnvifError):
        parse_response(b"<html>login</html>", 200)
    with pytest.raises(OnvifError, match="HTTP 401"):
        parse_response(b"Unauthorized", 401)


def test_largest_profile_is_main_and_smallest_is_sub():
    profiles = [
        Profile("small", "small", "H264", 640, 360, False, "rtsp://cam/sub"),
        Profile("large", "large", "H264", 1920, 1080, True, "rtsp://cam/main"),
        Profile("none", "none", "H264", 3840, 2160, False, None),
    ]
    main, sub = pick_streams(profiles)
    assert main.token == "large"
    assert sub.token == "small"
    assert pick_streams(profiles[1:2]) == (profiles[1], None)


def test_uri_path_keeps_the_query_and_port():
    assert uri_path("rtsp://192.168.1.104:554/Streaming/Channels/101?transportmode=unicast") == (
        "/Streaming/Channels/101?transportmode=unicast",
        554,
    )
    assert uri_path("rtsp://camera/live/ch00_0") == ("/live/ch00_0", None)


def test_parse_response_returns_the_body():
    body = parse_response(PROFILES_RESPONSE, 200)
    assert ElementTree.iselement(body)
