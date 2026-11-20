import socket
import struct

import pytest

from connector_agent import mdns
from connector_agent.mdns import SERVICE, Advertiser


def make_advertiser(**kwargs):
    return Advertiser(
        "Front Door",
        8765,
        "192.168.1.20",
        {"code": "123456", "version": "1.0", "state": "pairing"},
        **kwargs,
    )


def build_query(questions, flags=0):
    out = struct.pack("!HHHHHH", 0, flags, len(questions), 0, 0, 0)
    for name, qtype, unicast in questions:
        out += mdns.encode_name(name) + struct.pack("!HH", qtype, 1 | (0x8000 if unicast else 0))
    return out


def read_name(data, pos):
    labels = []
    while data[pos]:
        length = data[pos]
        labels.append(data[pos + 1 : pos + 1 + length].decode())
        pos += 1 + length
    return ".".join(labels), pos + 1


def parse_response(data):
    _, flags, qd, an, _, _ = struct.unpack_from("!HHHHHH", data, 0)
    assert qd == 0
    pos = 12
    records = []
    for _ in range(an):
        name, pos = read_name(data, pos)
        rtype, klass, ttl, rdlen = struct.unpack_from("!HHIH", data, pos)
        pos += 10
        records.append((name, rtype, klass, ttl, data[pos : pos + rdlen]))
        pos += rdlen
    return flags, records


class FakeTransport:
    def __init__(self):
        self.sent = []

    def sendto(self, data, addr=None):
        self.sent.append((data, addr))

    def close(self):
        pass


def test_encode_name_basic():
    assert mdns.encode_name("a.local.") == b"\x01a\x05local\x00"
    assert mdns.encode_name("a.local") == b"\x01a\x05local\x00"


def test_encode_name_limits():
    assert mdns.encode_name("a" * 63 + ".local")[0] == 63
    with pytest.raises(ValueError):
        mdns.encode_name("a" * 64 + ".local")
    with pytest.raises(ValueError):
        mdns.encode_name(".".join(["a" * 60] * 5))


def test_instance_name_truncated_on_character_boundary():
    adv = Advertiser(chr(233) * 40, 1, "10.0.0.1", {})
    assert len(adv.name.encode("utf-8")) <= 63
    assert adv.name == chr(233) * 31


def test_default_hostname():
    assert make_advertiser().hostname == "front-door.local."
    assert make_advertiser(hostname="Box.local").hostname == "Box.local."


def test_parse_query_two_questions_with_unicast_bit():
    data = build_query([(SERVICE, mdns.TYPE_PTR, True), ("Front-Door.local.", mdns.TYPE_A, False)])
    assert mdns.parse_query(data) == [(SERVICE, mdns.TYPE_PTR, True), ("front-door.local.", mdns.TYPE_A, False)]


def test_parse_query_ignores_response_and_garbage():
    assert mdns.parse_query(build_query([(SERVICE, mdns.TYPE_PTR, False)], flags=0x8400)) == []
    assert mdns.parse_query(b"") == []
    assert mdns.parse_query(b"\xff" * 5) == []
    assert mdns.parse_query(build_query([(SERVICE, mdns.TYPE_PTR, False)])[:-3]) == []


def test_parse_query_compression_loop_terminates():
    data = struct.pack("!HHHHHH", 0, 0, 1, 0, 0, 0) + b"\xc0\x0c" + struct.pack("!HH", 12, 1)
    assert mdns.parse_query(data) == []


def test_parse_query_follows_compression_pointer():
    first = mdns.encode_name(SERVICE)
    data = struct.pack("!HHHHHH", 0, 0, 2, 0, 0, 0) + first + struct.pack("!HH", 12, 1)
    data += b"\x03foo\xc0\x0c" + struct.pack("!HH", 1, 1)
    assert mdns.parse_query(data) == [(SERVICE, 12, False), ("foo." + SERVICE, 1, False)]


def test_ptr_response_has_four_records():
    adv = make_advertiser()
    flags, records = parse_response(mdns.build_response(adv.records_for(SERVICE, mdns.TYPE_PTR), 120))
    assert flags == 0x8400
    by_type = {rtype: (name, klass, ttl, rdata) for name, rtype, klass, ttl, rdata in records}
    assert set(by_type) == {mdns.TYPE_PTR, mdns.TYPE_SRV, mdns.TYPE_TXT, mdns.TYPE_A}
    assert all(item[2] == 120 for item in by_type.values())
    assert by_type[mdns.TYPE_PTR][1] == mdns.CLASS_IN
    for rtype in (mdns.TYPE_SRV, mdns.TYPE_TXT, mdns.TYPE_A):
        assert by_type[rtype][1] == mdns.CLASS_IN | mdns.CACHE_FLUSH
    instance_name = "Front Door." + SERVICE.rstrip(".")
    assert by_type[mdns.TYPE_PTR][0] == SERVICE.rstrip(".")
    assert by_type[mdns.TYPE_SRV][0] == instance_name
    srv = by_type[mdns.TYPE_SRV][3]
    assert struct.unpack_from("!HHH", srv, 0) == (0, 0, 8765)
    assert read_name(srv, 6)[0] == "front-door.local"
    txt = by_type[mdns.TYPE_TXT][3]
    pairs = []
    pos = 0
    while pos < len(txt):
        pairs.append(txt[pos + 1 : pos + 1 + txt[pos]].decode())
        pos += 1 + txt[pos]
    assert pairs == ["code=123456", "version=1.0", "state=pairing"]
    assert by_type[mdns.TYPE_A][3] == socket.inet_aton("192.168.1.20")


def test_other_queries():
    adv = make_advertiser()
    assert adv.records_for("_other._tcp.local.", mdns.TYPE_PTR) == []
    assert adv.records_for("other.local.", mdns.TYPE_A) == []
    assert [r.rtype for r in adv.records_for(mdns.ENUMERATION, mdns.TYPE_PTR)] == [mdns.TYPE_PTR]
    assert [r.rtype for r in adv.records_for("front door." + SERVICE, mdns.TYPE_SRV)][0] == mdns.TYPE_SRV
    assert [r.rtype for r in adv.records_for("front door." + SERVICE, mdns.TYPE_TXT)] == [mdns.TYPE_TXT]
    assert len(adv.records_for("front door." + SERVICE, mdns.TYPE_ANY)) == 3
    assert [r.rtype for r in adv.records_for("front-door.local.", mdns.TYPE_A)] == [mdns.TYPE_A]


def test_datagram_handling_multicast_and_unicast():
    adv = make_advertiser()
    proto = mdns.Responder(adv)
    transport = FakeTransport()
    proto.connection_made(transport)
    proto.datagram_received(build_query([(SERVICE, mdns.TYPE_PTR, False)]), ("192.168.1.50", 5353))
    assert [addr for _, addr in transport.sent] == [(mdns.GROUP, mdns.PORT)]
    transport.sent.clear()
    proto.datagram_received(build_query([(SERVICE, mdns.TYPE_PTR, True)]), ("192.168.1.50", 40000))
    assert [addr for _, addr in transport.sent] == [("192.168.1.50", 40000)]
    transport.sent.clear()
    proto.datagram_received(build_query([("_other._tcp.local.", mdns.TYPE_PTR, False)]), ("192.168.1.50", 5353))
    proto.datagram_received(build_query([(SERVICE, mdns.TYPE_PTR, False)], flags=0x8400), ("192.168.1.50", 5353))
    proto.datagram_received(b"garbage", ("192.168.1.50", 5353))
    assert transport.sent == []


def test_update_and_goodbye_through_fake_transport():
    adv = make_advertiser()
    transport = FakeTransport()
    adv.transport = transport
    adv.update({"code": "", "state": "paired"})
    _, records = parse_response(transport.sent[-1][0])
    txt = next(rdata for _, rtype, _, _, rdata in records if rtype == mdns.TYPE_TXT)
    assert b"state=paired" in txt
    adv.announce(0)
    _, records = parse_response(transport.sent[-1][0])
    assert {ttl for _, _, _, ttl, _ in records} == {0}
    assert transport.sent[-1][1] == (mdns.GROUP, mdns.PORT)
