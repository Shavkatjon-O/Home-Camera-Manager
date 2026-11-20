package uz.smartsurveillance.tv.rtsp

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import uz.smartsurveillance.tv.v380.Codec
import uz.smartsurveillance.tv.v380.hex

class RtspTest {
    private val sdp = """
        v=0
        o=- 1 1 IN IP4 192.168.1.104
        s=Media Presentation
        c=IN IP4 0.0.0.0
        a=control:*
        m=video 0 RTP/AVP 96
        a=rtpmap:96 H265/90000
        a=control:rtsp://192.168.1.104:554/Streaming/Channels/102/trackID=1
        m=audio 0 RTP/AVP 104
        a=rtpmap:104 mpeg4-generic/16000/1
        a=fmtp:104 profile-level-id=15; streamtype=5; mode=AAC-hbr; config=1408;SizeLength=13; IndexLength=3; IndexDeltaLength=3; Profile=1;
        a=control:trackID=2
    """.trimIndent().replace("\n", "\r\n")

    @Test
    fun parsesCameraSdp() {
        val parsed = Sdp.parse(sdp)
        assertEquals("*", parsed.control)
        val video = parsed.video()!!
        assertEquals("H265", video.codec)
        assertEquals(90000, video.clock)
        assertEquals("rtsp://192.168.1.104:554/Streaming/Channels/102/trackID=1", Sdp.resolve("rtsp://x/", video.control))
        val audio = parsed.audio()!!
        assertEquals(16000, audio.clock)
        assertEquals(1, audio.channels)
        assertEquals("1408", audio.fmtp["config"])
        assertEquals("13", audio.fmtp["sizelength"])
        assertEquals("rtsp://h/s/trackID=2", Sdp.resolve("rtsp://h/s/", audio.control))
        assertEquals("rtsp://h/s", Sdp.resolve("rtsp://h/s", "*"))
        assertArrayEquals(byteArrayOf(0x14, 0x08), AacUnits.config("1408"))
        assertNull(AacUnits.config("abc"))
    }

    @Test
    fun parsesResponsesAndSessions() {
        val response = Messages.parseHead(listOf("RTSP/1.0 401 Unauthorized", "CSeq: 2", "WWW-Authenticate: Digest realm=\"IP Camera\", nonce=\"abc\""), "")!!
        assertEquals(401, response.status)
        assertEquals("Digest realm=\"IP Camera\", nonce=\"abc\"", response.header("WWW-Authenticate"))
        assertEquals("12345", Messages.session("12345;timeout=60"))
        assertEquals(60, Messages.timeoutSeconds("12345;timeout=60"))
        assertNull(Messages.parseHead(listOf("HTTP/1.1 200 OK"), ""))
        val request = String(Messages.request("OPTIONS", "rtsp://h/p", 3, listOf("Session" to "9")))
        assertEquals("OPTIONS rtsp://h/p RTSP/1.0\r\nCSeq: 3\r\nUser-Agent: smart-surveillance-tv\r\nSession: 9\r\n\r\n", request)
    }

    @Test
    fun computesDigestLikeRfc2617() {
        val challenge = Messages.challenge("Digest realm=\"testrealm@host.com\", qop=\"auth,auth-int\", nonce=\"dcd98b7102dd2f0e8b11d0f600bfb0c093\", opaque=\"5ccc069c403ebaf9f0171e9517f40e41\"")
        assertEquals("digest", challenge["scheme"])
        val header = Messages.digest(challenge, "GET", "/dir/index.html", "Mufasa", "Circle Of Life", 1, "0a4f113b")
        assertTrue(header.contains("response=\"6629fae49393a05397450978507c4ef1\""))
        assertTrue(header.contains("qop=auth, nc=00000001, cnonce=\"0a4f113b\""))
        val plain = Messages.digest(mapOf("realm" to "r", "nonce" to "n"), "DESCRIBE", "rtsp://h/p", "u", "p", 1, "c")
        val expected = Messages.md5(Messages.md5("u:r:p") + ":n:" + Messages.md5("DESCRIBE:rtsp://h/p"))
        assertTrue(plain.contains("response=\"$expected\""))
        assertFalse(plain.contains("qop"))
    }

    private fun rtp(sequence: Int, timestamp: Long, marker: Boolean, payload: ByteArray): ByteArray {
        val header = ByteArray(12)
        header[0] = 0x80.toByte()
        header[1] = ((if (marker) 0x80 else 0) or 96).toByte()
        header[2] = (sequence shr 8).toByte()
        header[3] = sequence.toByte()
        for (i in 0 until 4) header[4 + i] = (timestamp shr (24 - 8 * i)).toByte()
        return header + payload
    }

    @Test
    fun parsesRtpHeaders() {
        val packet = rtp(65535, 0x01020304L, true, byteArrayOf(1, 2, 3))
        val parsed = parseRtp(packet, packet.size)!!
        assertTrue(parsed.marker)
        assertEquals(96, parsed.payloadType)
        assertEquals(65535, parsed.sequence)
        assertEquals(0x01020304L, parsed.timestamp)
        assertEquals(12, parsed.offset)
        assertEquals(3, parsed.length)
        assertNull(parseRtp(ByteArray(5), 5))
    }

    @Test
    fun rebuildsHevcAccessUnits() {
        val units = ArrayList<Pair<ByteArray, Boolean>>()
        val depacketizer = VideoDepacketizer(Codec.Hevc) { data, key -> units += data to key }
        val vps = byteArrayOf(0x40, 0x01, 0x0C)
        val sps = byteArrayOf(0x42, 0x01, 0x01, 0x02)
        val aggregate = byteArrayOf(0x60, 0x01, 0, 3) + vps + byteArrayOf(0, 4) + sps
        val idrBody = ByteArray(10) { (it + 1).toByte() }
        val fuStart = byteArrayOf(0x62, 0x01, (0x80 or 19).toByte()) + idrBody.copyOfRange(0, 6)
        val fuEnd = byteArrayOf(0x62, 0x01, (0x40 or 0x26).toByte()) + idrBody.copyOfRange(6, 10)
        val p = byteArrayOf(0x02, 0x01, 0x55)
        for ((index, payload) in listOf(aggregate, fuStart, fuEnd).withIndex()) {
            val packet = rtp(10 + index, 9000, index == 2, payload)
            depacketizer.push(packet, parseRtp(packet, packet.size)!!)
        }
        val next = rtp(13, 15000, true, p)
        depacketizer.push(next, parseRtp(next, next.size)!!)
        assertEquals(2, units.size)
        val expected = byteArrayOf(0, 0, 0, 1) + vps + byteArrayOf(0, 0, 0, 1) + sps + byteArrayOf(0, 0, 0, 1, 0x26, 0x01) + idrBody
        assertEquals(expected.hex(), units[0].first.hex())
        assertTrue(units[0].second)
        assertEquals((byteArrayOf(0, 0, 0, 1) + p).hex(), units[1].first.hex())
        assertFalse(units[1].second)
    }

    @Test
    fun dropsUnitsWithLostPackets() {
        val units = ArrayList<ByteArray>()
        val depacketizer = VideoDepacketizer(Codec.Hevc) { data, _ -> units += data }
        val first = rtp(1, 100, false, byteArrayOf(0x62, 0x01, (0x80 or 1).toByte(), 7))
        val third = rtp(3, 100, true, byteArrayOf(0x62, 0x01, (0x40 or 1).toByte(), 8))
        depacketizer.push(first, parseRtp(first, first.size)!!)
        depacketizer.push(third, parseRtp(third, third.size)!!)
        assertTrue(units.isEmpty())
        val good = rtp(4, 200, true, byteArrayOf(0x02, 0x01, 9))
        depacketizer.push(good, parseRtp(good, good.size)!!)
        assertEquals(1, units.size)
    }

    @Test
    fun rebuildsAvcUnits() {
        val units = ArrayList<Pair<ByteArray, Boolean>>()
        val depacketizer = VideoDepacketizer(Codec.Avc) { data, key -> units += data to key }
        val start = rtp(1, 1, false, byteArrayOf(0x7C, 0x85.toByte(), 1, 2))
        val end = rtp(2, 1, true, byteArrayOf(0x7C, 0x45, 3))
        depacketizer.push(start, parseRtp(start, start.size)!!)
        depacketizer.push(end, parseRtp(end, end.size)!!)
        assertEquals("0000000165010203", units.single().first.hex())
        assertTrue(units.single().second)
    }

    @Test
    fun splitsAacHbrUnits() {
        val payload = byteArrayOf(0, 32, (5 shr 5).toByte(), ((5 shl 3) and 0xFF).toByte(), (3 shr 5).toByte(), ((3 shl 3) and 0xFF).toByte()) +
            byteArrayOf(1, 2, 3, 4, 5) + byteArrayOf(6, 7, 8)
        val units = AacUnits.split(payload, 0, payload.size)
        assertEquals(listOf(6 to 5, 11 to 3), units)
    }
}
