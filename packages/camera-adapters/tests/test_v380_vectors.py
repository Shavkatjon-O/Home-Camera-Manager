import hashlib

import pytest

from camera_adapters.v380 import annexb, audio, crypto, discovery, framing, records, sps

DEVICE = 12345678
TICKET = 0x0BADF00D


def h(text):
    return bytes.fromhex(text.replace(" ", "").replace("\n", ""))


def sha(data):
    return hashlib.sha256(data).hexdigest()


def dump(lines, size):
    out = bytearray(size)
    for line in lines.strip().splitlines():
        offset, rest = line.split(None, 1)
        data = h(rest)
        out[int(offset, 16) : int(offset, 16) + len(data)] = data
    return bytes(out)


@pytest.mark.parametrize(
    ("password", "key", "c1", "field"),
    [
        (
            "secret123",
            b"ABCDEFGHIJKLMNOP",
            "877a073e728a8f2612a3d537c9058acf b70716297df9c38a4afd38f7ee8e96d2 b70716297df9c38a4afd38f7ee8e96d2",
            "4142434445464748494a4b4c4d4e4f50 2b82c0e2ca5512945596ae4038203fdb"
            "6a39ed52bf5232bf033df604f4f0aa9c 6a39ed52bf5232bf033df604f4f0aa9c",
        ),
        (
            "admin",
            b"0123456789abcdef",
            "cc07381ec8f7df462a4aeb239f5b4098 b70716297df9c38a4afd38f7ee8e96d2 b70716297df9c38a4afd38f7ee8e96d2",
            "30313233343536373839616263646566 5c62f757b324ba63585f8280c2b3a94d"
            "38a32a3a630f686211ccbf9620cdbbe9 38a32a3a630f686211ccbf9620cdbbe9",
        ),
        (
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV",
            b"ZYXWVUTSRQPONMLK",
            "63713533828428669313915490a4ce80 095115bd6eda15f19a07c3f7f42284fe 455bfba38d23911333505c1eed90d58d",
            "5a595857565554535251504f4e4d4c4b 512e4b40a9bd9aadfc0ad8a9fb40a4f5"
            "31c3cedaf4479788f9586992e2d02dda 99e4098bbcaf79e051ae083a211fb1ee",
        ),
        (
            "",
            b"AAAAAAAAAAAAAAAA",
            "b70716297df9c38a4afd38f7ee8e96d2 b70716297df9c38a4afd38f7ee8e96d2 b70716297df9c38a4afd38f7ee8e96d2",
            "41414141414141414141414141414141 6cf3947b67385773ea780edef355f4b3"
            "6cf3947b67385773ea780edef355f4b3 6cf3947b67385773ea780edef355f4b3",
        ),
    ],
)
def test_password_fields_match_the_vectors(password, key, c1, field):
    plain = password.encode()[:48].ljust(48, b"\0")
    assert crypto.encrypt_blocks(crypto.FIXED_KEY, plain) == h(c1)
    assert crypto.password_field(password, key) == h(field)
    assert crypto.recover_password(h(field)) == plain


def test_random_keys_are_letters_and_digits():
    for _ in range(50):
        key = crypto.random_key()
        assert len(key) == 16
        assert all(chr(byte) in crypto.KEY_ALPHABET for byte in key)
    field = crypto.password_field("secret123")
    assert crypto.recover_password(field).rstrip(b"\0") == b"secret123"


def test_passwords_are_truncated_and_non_ascii_refused():
    long = "x" * 60
    assert crypto.recover_password(crypto.password_field(long, b"A" * 16)) == b"x" * 48
    with pytest.raises(ValueError):
        crypto.password_field("p" + chr(0xE4) + "ss")
    with pytest.raises(ValueError):
        crypto.password_field("secret", b"not-a-good-key!!")


@pytest.mark.parametrize(
    ("ticket", "key"),
    [
        (0x12345678, "785634125c79142c46238161f00d8082"),
        (0x0BADF00D, "0df0ad0b5c79142c46238161f00d8082"),
        (0x00000000, "000000005c79142c46238161f00d8082"),
        (0xFFFFFFFF, "ffffffff5c79142c46238161f00d8082"),
    ],
)
def test_media_keys_match_the_vectors(ticket, key):
    assert crypto.media_key(ticket) == h(key)


def test_the_login_request_matches_the_vector():
    field = crypto.password_field("secret123", b"ABCDEFGHIJKLMNOP")
    request = records.login_request(DEVICE, "admin", field)
    assert len(request) == 520
    assert sha(request) == "39f6f9e0a0985126f5b96f77f3ad296c5e727b3cdb3a361430b59d0059bf5055"
    expected = dump(
        """
        0000  8f 04 00 00 78 00 00 00 1f 01 00 00 00 4e 61 bc
        0030  00 61 64 6d 69 6e 00 00 00 00 00 00 00 00 00 00
        0050  00 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f
        0060  50 2b 82 c0 e2 ca 55 12 94 55 96 ae 40 38 20 3f
        0070  db 6a 39 ed 52 bf 52 32 bf 03 3d f6 04 f4 f0 aa
        0080  9c 6a 39 ed 52 bf 52 32 bf 03 3d f6 04 f4 f0 aa
        0090  9c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
        """,
        520,
    )
    assert request == expected


def test_the_login_reply_parses():
    reply = dump(
        """
        0000  90 04 00 00 e9 03 00 00 00 00 00 00 20 0d f0 ad
        0010  0b 77 00 00 00 01 02 02 01 00 00 00 00 00 00 00
        """,
        256,
    )
    parsed = records.parse_login_reply(reply)
    assert parsed.result == 1001 and parsed.accepted
    assert parsed.device_version == 32 and parsed.encrypted
    assert parsed.ticket == TICKET
    assert parsed.session_id == 119
    assert (parsed.device_type, parsed.camera_type, parsed.vendor_id) == (1, 2, 0x0102)
    assert parsed.domain == ""
    assert crypto.media_key(parsed.ticket) == h("0df0ad0b5c79142c46238161f00d8082")
    assert records.parse_login_reply(reply[:21]).ticket == TICKET


def test_short_or_foreign_login_replies_are_protocol_errors():
    from camera_adapters.v380.errors import ProtocolError

    with pytest.raises(ProtocolError):
        records.parse_login_reply(bytes(20))
    with pytest.raises(ProtocolError):
        records.parse_login_reply(bytes(256))


def test_stream_login_requests_match_the_vectors():
    sub = records.stream_login_request(DEVICE, TICKET, True, records.Stream.SUB)
    main = records.stream_login_request(DEVICE, TICKET, False, records.Stream.MAIN)
    assert sha(sub) == "6a1891da109407f5196ed67a84a7e9dbc233ffc08a871d6152d62d658eb5a989"
    assert sha(main) == "4cc341e6c68adb2279aaf7387f0d6b614819d2cb202a8d5402825abcd1793668"
    assert sub[:32] == h("2d 01 00 00 4e 61 bc 00 00 00 00 00 14 00 0d f0 ad 0b 00 00 00 00 01 10" + " 00" * 8)
    assert main[:32] == h(
        "2d 01 00 00 4e 61 bc 00 00 00 00 00 14 00 0d f0 ad 0b 00 00 00 00 00 10 00 00 01" + " 00" * 5
    )


def test_the_short_stream_login_reply_parses():
    reply = h("91 01 00 00 e9 03 00 00 14 00 80 02 00 00 d0 02") + bytes(16)
    parsed = records.parse_stream_login_reply(reply)
    assert parsed.result == 1001 and parsed.accepted
    assert parsed.comm_version == 20
    assert (parsed.width, parsed.height) == (640, 720)
    assert records.parse_stream_login_reply(reply[:8]).width == 0
    refused = records.parse_stream_login_reply(h("91 01 00 00") + (-11).to_bytes(4, "little", signed=True))
    assert not refused.accepted


def test_the_start_request_matches_the_vector():
    start = records.start_request()
    assert sha(start) == "c973a8440dcfd78469733ca5f0013f9afbf44c4165d051baf1d0fdac2e930f85"
    assert start[:16] == h("2f 01 00 00 01 30" + " 00" * 10)


@pytest.mark.parametrize(
    ("header", "expected"),
    [
        ("7f 28 00 03 00 01 00 e8 03 00 00 00", (0x28, 3, 1, 1000)),
        ("7f 29 00 01 00 00 00 e1 10 00 00 00", (0x29, 1, 0, 4321)),
        ("7f 16 00 01 00 00 00 10 01 00 00 00", (0x16, 1, 0, 272)),
        ("7f 18 00 01 00 00 00 17 01 00 00 00", (0x18, 1, 0, 279)),
        ("7f 01 00 02 00 02 00 0a 00 00 00 00", None),
        ("7f 01 00 02 00 00 00 00 00 00 00 00", None),
        ("7f 01 00 02 00 00 00 21 4e 00 00 00", None),
        ("00 00 00 00 00 00 00 00 00 00 00 00", None),
    ],
)
def test_fragment_headers_match_the_vectors(header, expected):
    parsed = framing.parse_fragment_header(h(header))
    if expected is None:
        assert parsed is None
    else:
        assert (parsed.type, parsed.count, parsed.index, parsed.length) == expected
        assert framing.fragment_header(parsed) == h(header)


VIDEO_CIPHER = """
    0000  ff 72 87 80 ba f0 2c ca 26 d1 07 36 3b 38 5c 78
    0010  70 17 9b 65 84 90 fa 69 b6 cb 09 b4 c0 4a 48 a7
    0020  bc dd ff 2e b0 b0 c1 52 74 32 13 be 14 97 41 f1
    0030  36 36 7e c8 e4 22 4a eb 78 f9 b5 58 3d 9b 86 e0
    0040  40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f
    0050  37 c4 52 ec 60 3e 61 87 e0 aa 3c 27 68 50 3c 66
    0060  fb 96 2a 77 98 c2 5c f1 0e ad 51 6f d9 d6 f1 5e
    0070  6b f4 a4 ce f0 8d c1 18 ea 04 18 49 f0 db c0 d4
    0080  c2 1c e2 59 44 f5 aa 59 8b 3b d0 de cd ef 49 eb
    0090  90 91 92 93 94 95
    """
AUDIO_CIPHER = """
    0000  ff 72 87 80 ba f0 2c ca 26 d1 07 36 3b 38 5c 78
    0010  70 17 9b 65 84 90 fa 69 b6 cb 09 b4 c0 4a 48 a7
    0020  20 21 22 23 24 25 26 27
    """


def test_media_decryption_matches_the_vectors():
    cipher = crypto.MediaCipher(crypto.media_key(TICKET), 20)
    video = dump(VIDEO_CIPHER, 150)
    assert cipher.decrypt_video(video) == bytes(range(150))
    assert cipher.encrypt_video(bytes(range(150))) == video
    sound = dump(AUDIO_CIPHER, 40)
    assert cipher.decrypt_audio(sound) == bytes(range(40))
    assert cipher.encrypt_audio(bytes(range(40))) == sound
    assert crypto.MediaCipher(cipher.key, 21).decrypt_video(sound) == bytes(range(40))
    assert cipher.decrypt_video(bytes(range(63))) == bytes(range(63))


FRAME = framing.frame_header(framing.FrameHeader(9, 0, 15, 1234567890123)) + bytes(i % 256 for i in range(2500))


def fragment(frame_type, count, index, data):
    return framing.Fragment(framing.FragmentHeader(frame_type, count, index, len(data)), data)


def run(fragments):
    assembler = framing.Reassembler()
    delivered = [assembler.push(item) for item in fragments]
    return delivered, assembler.dropped


def test_three_fragments_in_order_complete_a_frame():
    delivered, dropped = run(
        [
            fragment(0x28, 3, 0, FRAME[0:1000]),
            fragment(0x28, 3, 1, FRAME[1000:2000]),
            fragment(0x28, 3, 2, FRAME[2000:]),
        ]
    )
    assert delivered[:2] == [None, None]
    assert delivered[2].payload == FRAME[16:] and len(delivered[2].payload) == 2500
    assert delivered[2].header == framing.FrameHeader(9, 0, 15, 1234567890123)
    assert dropped == 0


def test_a_gap_drops_the_frame_and_a_new_one_starts():
    delivered, dropped = run(
        [fragment(0x29, 3, 0, FRAME[0:100]), fragment(0x29, 3, 2, FRAME[200:300]), fragment(0x29, 1, 0, FRAME[0:116])]
    )
    assert delivered[:2] == [None, None]
    assert len(delivered[2].payload) == 100
    assert dropped == 1


def test_a_changed_count_drops_the_frame():
    delivered, dropped = run([fragment(0x29, 2, 0, FRAME[0:50]), fragment(0x29, 3, 1, FRAME[50:100])])
    assert delivered == [None, None]
    assert dropped == 1


def test_a_frame_shorter_than_its_header_is_dropped():
    delivered, dropped = run([fragment(0x29, 1, 0, FRAME[0:10])])
    assert delivered == [None]
    assert dropped == 0


def test_audio_between_video_fragments_is_reassembled_apart():
    delivered, dropped = run(
        [
            fragment(0x28, 2, 0, FRAME[0:600]),
            fragment(0x16, 1, 0, FRAME[0:272]),
            fragment(0x5B, 1, 0, bytes(8)),
            fragment(0x28, 2, 1, FRAME[600:]),
        ]
    )
    assert delivered[0] is None and delivered[2] is None
    assert delivered[1].type == 0x16 and len(delivered[1].data) == 272
    assert delivered[3].type == 0x28 and delivered[3].data == FRAME
    assert dropped == 0


def test_repeated_and_reordered_fragments_never_deliver():
    delivered, dropped = run(
        [fragment(0x29, 3, 0, FRAME[:10]), fragment(0x29, 3, 1, FRAME[10:20]), fragment(0x29, 3, 1, FRAME[10:20])]
    )
    assert delivered == [None, None, None]
    assert dropped == 1
    delivered, dropped = run([fragment(0x29, 2, 1, FRAME[:20]), fragment(0x29, 2, 0, FRAME[:20])])
    assert delivered == [None, None]


SPS = [
    (
        "42010101400000030090000003000003005aa0050200b459e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104",
        (640, 720),
        174,
        "42010101400000030090000003000003005aa0050200b459ebb91295cd404080b8400000030040000003039515ff7840fa01775f080410",
    ),
    (
        "420101014000000300900000030000030096a0012020028859e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104",
        (2304, 2592),
        182,
        "420101014000000300900000030000030096a0012020028859ebb91295cd404080b8400000030040000003039515ff7840fa01775f080410",
    ),
    (
        "420101014000000300900000030000030096a003c080087167a5b91295cd404080b8400000030040000003039403ff784000b71a0000895457c20104",
        (1920, 2160),
        180,
        "420101014000000300900000030000030096a003c080087167aee44a5735010202e10000030001000003000e500ffde10002dc68000225515f080410",
    ),
]


@pytest.mark.parametrize(("raw", "size", "bit", "rewritten"), SPS)
def test_sps_sizes_reorder_fields_and_rewrites_match_the_vectors(raw, size, bit, rewritten):
    parsed = sps.parse_h265_sps(h(raw))
    assert (parsed.width, parsed.height) == size
    assert parsed.chroma_format == 1
    assert parsed.reorder_fields == ((bit, 3),)
    assert parsed.reorder_values == (1,)
    out = sps.rewrite_reorder(h(raw))
    assert out == h(rewritten)
    assert len(out) == len(h(raw))
    again = sps.parse_h265_sps(out)
    assert (again.width, again.height) == size and again.reorder_values == (0,)
    assert sps.rewrite_reorder(out) == out


def test_emulation_prevention_matches_the_vectors():
    assert sps.insert_emulation(h("00 00 01 00 00 00")) == h("00 00 03 01 00 00 03 00")
    assert sps.remove_emulation(h("00 00 03 01 00 00 03 02")) == h("00 00 01 00 00 02")


def test_the_rewrite_replaces_the_sps_of_an_access_unit():
    raw, _, _, rewritten = SPS[0]
    au = b"\0\0\0\1" + h("40010c01ffff01400000030090000003000003005a95980900") + b"\0\0\0\1" + h(raw)
    au += b"\0\0\0\1" + h("4401c172b46240") + b"\0\0\0\1\x26\x01" + bytes(range(50))
    out = sps.rewrite_access_unit(au)
    assert h(rewritten) in out and h(raw) not in out
    assert sps.picture_size(out, annexb.Codec.H265) == (640, 720)


def key_access_unit():
    raw = SPS[0][0]
    return (
        b"\0\0\0\1"
        + h("40 01 0c 01 ff ff 01 40 00 00 03 00 90 00 00 03 00 00 03 00 5a 95 98 09 00")
        + b"\0\0\0\1"
        + h(raw)
        + b"\0\0\0\1"
        + h("44 01 c1 72 b4 62 40")
        + b"\0\0\0\1\x26\x01"
        + bytes(i % 256 for i in range(300))
    )


@pytest.mark.parametrize(
    ("payload", "output"),
    [
        (h("ab ab cd 00 00 00 01 40 01 02"), h("00 00 00 01 40 01 02")),
        (h("00 00 01 40"), h("00 00 01 40")),
        (h("00 00 00 01 40"), h("00 00 00 01 40")),
        (bytes(range(1, 16)) + h("00 00 01 40"), h("00 00 01 40")),
        (bytes(range(1, 15)) + h("00 00 00 01 40"), h("00 00 00 01 40")),
        (bytes(range(1, 17)) + h("00 00 00 01 40"), None),
        (bytes([7] * 40), None),
    ],
)
def test_start_code_alignment_matches_the_vectors(payload, output):
    assert annexb.align(payload) == output


def test_codec_identification_matches_the_vectors():
    au = key_access_unit()
    assert len(au) == 405
    assert sha(au) == "4fa878bcbf542199aa5f3fb8f6db637133a207ed0b97d7b8c99256f4d506d6a0"
    assert annexb.identify_codec(au) == annexb.Codec.H265
    assert [annexb.h265_type(au[b:e]) for _, b, e in annexb.nal_units(au)] == [32, 33, 34, 19]
    avc = h("00 00 00 01 67 42 00 1f 00 00 00 01 68 ce 3c 80 00 00 00 01 65 88 84")
    assert annexb.identify_codec(avc) == annexb.Codec.H264
    assert [annexb.h264_type(avc[b:e]) for _, b, e in annexb.nal_units(avc)] == [7, 8, 5]
    lone = h("00 00 00 01 26 01 af")
    assert annexb.identify_codec(lone) is None
    assert annexb.h265_type(lone[4:]) == 19


def test_adpcm_matches_the_vectors():
    assert audio.adpcm_decode(h("00 00 00 00 07")) == [0, 11, 13]
    block = h("e8 03 0a 00") + bytes(range(252))
    samples = audio.adpcm_decode(block)
    assert len(samples) == 505
    assert samples[:8] == [1000, 1002, 1004, 1010, 1011, 1018, 1019, 1027]
    assert samples[-1] == -32768
    assert sha(audio.pcm_bytes(samples)) == "5afe464b1e3fe4ebc142904fb62c596a00a70445e1d66541a9835c83878d2232"


def test_alaw_matches_the_vectors():
    assert audio.alaw_decode(h("d5 55 aa 2a 00 80")) == [8, -8, 32256, -32256, -5504, 5504]
    for value in (8, -8, 32256, -32256, -5504, 5504):
        assert audio.alaw_decode(audio.alaw_encode([value])) == [value]
    assert audio.alaw_encode(audio.alaw_decode(bytes(range(256)))) == bytes(range(256))


def test_the_adts_header_matches_the_vector():
    adts = audio.parse_adts(h("ff f9 6c 40 20 ff fc"))
    assert (adts.object_type, adts.frequency_index, adts.sample_rate, adts.channels) == (2, 11, 8000, 1)
    assert (adts.header_size, adts.frame_length) == (7, 263)
    assert adts.config == h("15 88")
    assert audio.parse_adts(h("00 01 02 03 04 05 06")) is None


def test_discovery_matches_the_vectors():
    assert discovery.SEARCH == h("4e 56 44 45 56 53 45 41 52 43 48 5e 31 30 30")
    reply = "NVDEVRESULT^1^AA:BB:CC:DD:EE:FF^192.168.1.237^255.255.255.0^192.168.1.1^x^x^x^x^x^x^12345678^x"
    camera = discovery.parse_reply(reply)
    assert camera == discovery.DiscoveredCamera(
        host="192.168.1.237", mac="AA:BB:CC:DD:EE:FF", mask="255.255.255.0", gateway="192.168.1.1", device_id="12345678"
    )
    assert discovery.parse_reply("NVDEVSEARCH^100") is None
    assert discovery.parse_reply("NVDEVRESULT^1^2") is None


@pytest.mark.parametrize(
    ("move", "record"),
    [
        ("left", "aa 00 00 00 e8 03 e8 03 e9 03 e8 03 00 00 01 00"),
        ("right", "aa 00 00 00 e8 03 e8 03 ea 03 e8 03 00 00 01 00"),
        ("up", "aa 00 00 00 e8 03 e8 03 e8 03 eb 03 00 00 01 00"),
        ("down", "aa 00 00 00 e8 03 e8 03 e8 03 ec 03 00 00 01 00"),
        ("stop", "aa 00 00 00 e8 03 e8 03 e8 03 e8 03 00 00 01 00"),
    ],
)
def test_ptz_records_match_the_vectors(move, record):
    assert records.ptz_record(records.PtzMove(move)) == h(record)


def test_light_siren_and_picture_records_match_the_vectors():
    assert records.light_record(records.LightMode.ON) == h("c4 00 00 00 e9 03 00 00 00 01 00 00 00 00 00 00")
    assert records.light_record(records.LightMode.OFF) == h("c4 00 00 00 ea 03 00 00 00 01 00 00 00 00 00 00")
    assert records.light_record(records.LightMode.AUTO) == h("c4 00 00 00 eb 03 00 00 00 01 00 00 00 00 00 00")
    assert records.siren_record(True) == h("b9 00 00 00 e9 03 00 00 02 00 00 00 00 00 00 00")
    assert records.siren_record(False) == h("b9 00 00 00 ea 03 00 00 01 00 00 00 00 00 00 00")
    picture = records.PictureMode
    assert records.picture_record(picture.COLOUR) == h("c5 00 00 00 e9 03 00 00 00 01 00 00 00 00 00 00")
    assert records.picture_record(picture.BLACK_AND_WHITE) == h("c5 00 00 00 ea 03 00 00 00 01 00 00 00 00 00 00")
    assert records.picture_record(picture.AUTO) == h("c5 00 00 00 eb 03 00 00 00 01 00 00 00 00 00 00")
    assert records.flip_record() == h("be 00 00 00 e8 03 00 00 00 00 00 00 00 00 00 00")


def test_the_fragment_reader_cuts_split_reads_and_resynchronises():
    stream = b""
    for item in (
        fragment(0x29, 1, 0, FRAME[:116]),
        fragment(0x16, 1, 0, FRAME[:272]),
    ):
        stream += framing.fragment_header(item.header) + item.payload
    reader = framing.FragmentReader()
    out = []
    for offset in range(0, len(stream), 7):
        out += reader.feed(stream[offset : offset + 7])
    assert [item.header.type for item in out] == [0x29, 0x16]
    reader = framing.FragmentReader()
    garbage = bytes([1, 2, 3, 0x7F, 0x01, 0, 2, 0, 2, 0, 10, 0, 0, 0]) + stream
    out = reader.feed(garbage)
    assert [item.header.type for item in out] == [0x29, 0x16]
    assert reader.resyncs == 1


def test_the_fragment_reader_gives_up_after_64_invalid_headers():
    from camera_adapters.v380.errors import FramingLost

    reader = framing.FragmentReader()
    with pytest.raises(FramingLost):
        reader.feed(bytes([0x7F, 0, 0, 0, 0]) * 70 + bytes(12))


def test_marker_bytes_in_media_do_not_capture_the_search():
    real = fragment(0x29, 1, 0, FRAME[:116])
    stream = framing.fragment_header(real.header) + real.payload
    reader = framing.FragmentReader()
    out = reader.feed(bytes([0x00, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x28, 0x00, 0x03, 0x00]) + stream)
    assert [item.header.type for item in out] == [0x29]
    assert len(out[0].payload) == 116


async def test_a_password_outside_printable_ascii_is_refused_before_connecting():
    from camera_adapters.v380.client import Camera, login
    from camera_adapters.v380.errors import ProtocolError

    with pytest.raises(ProtocolError):
        await login(Camera("127.0.0.1", DEVICE, "p" + chr(0xE4) + "ss", port=1))
