package uz.smartsurveillance.tv.v380

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class RecordsTest {
    private fun dump(lines: String, size: Int): ByteArray {
        val out = ByteArray(size)
        for (line in lines.trim().lines()) {
            val parts = line.trim().split(Regex("\\s+"))
            val offset = parts[0].toInt(16)
            for ((i, part) in parts.drop(1).withIndex()) out[offset + i] = part.toInt(16).toByte()
        }
        return out
    }

    @Test
    fun loginRequestMatchesTheVector() {
        val field = Crypto.passwordField("secret123", "ABCDEFGHIJKLMNOP".toByteArray())
        val request = Records.login(12345678, "admin", field)
        assertEquals(520, request.size)
        assertEquals("39f6f9e0a0985126f5b96f77f3ad296c5e727b3cdb3a361430b59d0059bf5055", sha256(request))
        val expected = dump(
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
        assertEquals(expected.hex(), request.hex())
    }

    @Test
    fun loginReplyParses() {
        val reply = dump(
            """
            0000  90 04 00 00 e9 03 00 00 00 00 00 00 20 0d f0 ad
            0010  0b 77 00 00 00 01 02 02 01 00 00 00 00 00 00 00
            """,
            256,
        )
        val parsed = Records.loginReply(reply)
        assertTrue(parsed.accepted)
        assertEquals(1001, parsed.result)
        assertEquals(32, parsed.deviceVersion)
        assertEquals(0x0badf00dL, parsed.ticket)
        assertEquals(119L, parsed.sessionId)
        assertEquals("0df0ad0b5c79142c46238161f00d8082", Crypto.mediaKey(parsed.ticket).hex())
        assertEquals(32, Records.loginReply(reply.copyOf(21)).deviceVersion)
        assertThrows(V380Exception::class.java) { Records.loginReply(reply.copyOf(20)) }
        val other = reply.copyOf()
        other[0] = 0x91.toByte()
        assertThrows(V380Exception::class.java) { Records.loginReply(other) }
    }

    @Test
    fun refusalsAreNamed() {
        assertEquals("Unknown user name", Records.refusal(1011))
        assertEquals("Wrong password", Records.refusal(1012))
        assertEquals("Wrong device id", Records.refusal(1018))
        assertEquals("Login refused with code 1005", Records.refusal(1005))
    }

    @Test
    fun streamLoginsMatchTheVectors() {
        val sub = Records.streamLogin(12345678, 0x0badf00d, StreamKind.Sub, sound = true)
        assertEquals("6a1891da109407f5196ed67a84a7e9dbc233ffc08a871d6152d62d658eb5a989", sha256(sub))
        assertEquals(
            dump(
                """
                0000  2d 01 00 00 4e 61 bc 00 00 00 00 00 14 00 0d f0
                0010  ad 0b 00 00 00 00 01 10 00 00 00 00 00 00 00 00
                """,
                256,
            ).hex(),
            sub.hex(),
        )
        val main = Records.streamLogin(12345678, 0x0badf00d, StreamKind.Main, sound = false)
        assertEquals("4cc341e6c68adb2279aaf7387f0d6b614819d2cb202a8d5402825abcd1793668", sha256(main))
    }

    @Test
    fun shortStreamReplyParses() {
        val reply = dump("0000  91 01 00 00 e9 03 00 00 14 00 80 02 00 00 d0 02", 32)
        val parsed = Records.streamReply(reply)
        assertEquals(1001, parsed.result)
        assertFalse(parsed.refused)
        assertEquals(20, parsed.communicationVersion)
        assertEquals(VideoSize(640, 720), parsed.size)
        assertEquals(32, parsed.length)
        val eight = Records.streamReply(reply.copyOf(8))
        assertEquals(0, eight.communicationVersion)
        assertNull(eight.size)
        assertThrows(V380Exception::class.java) { Records.streamReply(reply.copyOf(7)) }
        val refused = reply.copyOf()
        refused.put32(4, -11L)
        assertTrue(Records.streamReply(refused).refused)
        refused.put32(4, -12L)
        assertTrue(Records.streamReply(refused).refused)
    }

    @Test
    fun startMatchesTheVector() {
        val start = Records.start()
        assertEquals("c973a8440dcfd78469733ca5f0013f9afbf44c4165d051baf1d0fdac2e930f85", sha256(start))
        assertEquals("2f010000013000000000000000000000", start.copyOf(16).hex())
    }

    @Test
    fun ptzRecordsMatchTheTable() {
        assertEquals("aa000000e803e803e903e80300000100", PtzMove.Left.record().hex())
        assertEquals("aa000000e803e803ea03e80300000100", PtzMove.Right.record().hex())
        assertEquals("aa000000e803e803e803eb0300000100", PtzMove.Up.record().hex())
        assertEquals("aa000000e803e803e803ec0300000100", PtzMove.Down.record().hex())
        assertEquals("aa000000e803e803e803e80300000100", PtzMove.Stop.record().hex())
    }

    @Test
    fun lightSirenAndPictureRecordsMatchTheTable() {
        assertEquals("c4000000e903000000010000" + "00000000", Commands.light(Commands.Light.On).hex())
        assertEquals("c4000000ea03000000010000" + "00000000", Commands.light(Commands.Light.Off).hex())
        assertEquals("c4000000eb03000000010000" + "00000000", Commands.light(Commands.Light.Auto).hex())
        assertEquals("b9000000e903000002000000" + "00000000", Commands.sirenOn().hex())
        assertEquals("b9000000ea03000001000000" + "00000000", Commands.sirenOff().hex())
        assertEquals("c5000000e903000000010000" + "00000000", Commands.picture(Commands.Picture.Colour).hex())
        assertEquals("c5000000ea03000000010000" + "00000000", Commands.picture(Commands.Picture.BlackAndWhite).hex())
        assertEquals("c5000000eb03000000010000" + "00000000", Commands.picture(Commands.Picture.Auto).hex())
        assertEquals("be000000e803000000000000" + "00000000", Commands.flip().hex())
    }
}
