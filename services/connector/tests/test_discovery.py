import ipaddress

from connector_agent.discovery import merge
from connector_agent.wsdiscovery import Match, parse_matches, probe_message

ANSWER = b"""<?xml version="1.0"?>
<e:Envelope xmlns:e="http://www.w3.org/2003/05/soap-envelope" xmlns:w="http://schemas.xmlsoap.org/ws/2004/08/addressing"
 xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery">
<e:Header><w:RelatesTo>urn:uuid:probe</w:RelatesTo></e:Header>
<e:Body><d:ProbeMatches><d:ProbeMatch>
<w:EndpointReference><w:Address>urn:uuid:device</w:Address></w:EndpointReference>
<d:Scopes>onvif://www.onvif.org/name/Simulated onvif://www.onvif.org/type/video_encoder</d:Scopes>
<d:XAddrs>http://192.168.1.20:8000/onvif/device_service</d:XAddrs>
</d:ProbeMatch></d:ProbeMatches></e:Body></e:Envelope>"""


def test_probe_answers_are_read_and_others_ignored():
    matches = parse_matches(ANSWER, "urn:uuid:probe")
    assert matches == [
        Match(
            "192.168.1.20",
            8000,
            ("http://192.168.1.20:8000/onvif/device_service",),
            ("onvif://www.onvif.org/name/Simulated", "onvif://www.onvif.org/type/video_encoder"),
            "urn:uuid:device",
        )
    ]
    assert parse_matches(ANSWER, "urn:uuid:other") == []
    assert parse_matches(b"<not xml") == []
    assert b"NetworkVideoTransmitter" in probe_message("urn:uuid:probe")


def test_merging_keeps_only_allowed_networks_and_marks_both():
    allowed = [ipaddress.ip_network("192.168.1.0/24")]
    matches = [
        Match("192.168.1.20", 8000, (), ("scope",), "e"),
        Match("172.31.251.5", 80, (), (), "e"),
    ]
    swept = {"192.168.1.20": [554], "192.168.1.30": [554, 80], "192.168.1.40": [22], "10.0.0.9": [554]}
    candidates = merge(matches, swept, allowed)
    assert set(candidates) == {"192.168.1.20", "192.168.1.30"}
    assert candidates["192.168.1.20"].found_by == "both" and candidates["192.168.1.20"].open_ports == [554, 8000]
    assert candidates["192.168.1.30"].found_by == "sweep"
