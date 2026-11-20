package uz.smartsurveillance.tv.v380

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class PacketsTest {
    @Test
    fun authRequestUsesTheLanLayout() {
        val password = ByteArray(64) { (it + 1).toByte() }
        val packet = Packets.auth(12345678L, "admin", password)
        assertEquals(520, packet.size)
        assertEquals(1167L, packet.u32(0))
        assertEquals(120L, packet.u32(4))
        assertEquals(31, packet[8].toInt())
        assertEquals(1L, packet.u32(9))
        assertEquals(12345678L, packet.u32(13))
        assertEquals("admin", String(packet, 49, 5))
        assertEquals(0, packet[54].toInt())
        assertEquals(1, packet[81].toInt())
        assertEquals(64, packet[144].toInt())
        assertEquals(0, packet[145].toInt())
    }

    @Test
    fun parsesAuthReply() {
        val reply = ByteArray(256)
        reply.put32(0, 1168)
        reply.put32(4, 1001)
        reply[12] = 32
        reply.put32(13, 0xDEADBEEFL)
        reply.put32(17, 77)
        val parsed = Packets.parseAuth(reply)!!
        assertTrue(parsed.ok)
        assertEquals(32, parsed.version)
        assertEquals(0xDEADBEEFL, parsed.ticket)
        assertEquals(77L, parsed.session)
        reply.put32(4, 1012)
        assertFalse(Packets.parseAuth(reply)!!.ok)
        assertEquals("Wrong password", Packets.authError(1012))
        assertNull(Packets.parseAuth(ByteArray(10)))
    }

    @Test
    fun streamLoginCarriesQualityAndAudio() {
        val sd = Packets.login(87654321L, 0xCAFEL, hd = false, audio = false)
        assertEquals(256, sd.size)
        assertEquals(301L, sd.u32(0))
        assertEquals(87654321L, sd.u32(4))
        assertEquals(20, sd.u16(12))
        assertEquals(0xCAFEL, sd.u32(14))
        assertEquals(4096L, sd.u32(22))
        assertEquals(0L, sd.u32(26))
        val hd = Packets.login(87654321L, 0xCAFEL, hd = true, audio = true)
        assertEquals(4097L, hd.u32(22))
        assertEquals(1L, hd.u32(26))
    }

    @Test
    fun parsesLoginReply() {
        val reply = ByteArray(32)
        reply.put32(0, 401)
        reply.put32(4, 1001)
        reply.put16(8, 20)
        reply.put32(10, 640)
        reply.put32(14, 720)
        val parsed = Packets.parseLogin(reply)!!
        assertTrue(parsed.ok)
        assertEquals(20, parsed.version)
        assertEquals(640L, parsed.width)
        assertEquals(720L, parsed.height)
        reply.put32(4, -11L)
        assertFalse(Packets.parseLogin(reply)!!.ok)
        val short = Packets.parseLogin(reply.copyOf(8))!!
        assertEquals(0L, short.width)
    }

    @Test
    fun startStreamAndPtzPackets() {
        val start = Packets.start()
        assertEquals(303L, start.u32(0))
        assertEquals(0x3001, start.u16(4))
        assertEquals("aa000000e803e803ea03e80300000100", Ptz.packet(PtzMove.Right).hex())
        assertEquals("aa000000e803e803e903e80300000100", Ptz.packet(PtzMove.Left).hex())
        assertEquals("aa000000e803e803e803eb0300000100", Ptz.packet(PtzMove.Up).hex())
        assertEquals("aa000000e803e803e803ec0300000100", Ptz.packet(PtzMove.Down).hex())
        assertEquals("aa000000e803e803e803e80300000100", Ptz.packet(PtzMove.Stop).hex())
    }
}
