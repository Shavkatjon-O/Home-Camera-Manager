package uz.smartsurveillance.tv.v380

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class FramesTest {
    private fun header(type: Int, total: Int, index: Int, length: Int): ByteArray {
        val header = ByteArray(12)
        header[0] = 0x7F
        header[1] = type.toByte()
        header.put16(3, total)
        header.put16(5, index)
        header.put16(7, length)
        return header
    }

    private fun frame(payload: ByteArray, id: Long = 5, timestamp: Long = 1_700_000_000_000L): ByteArray {
        val inner = ByteArray(16)
        inner.put32(0, id)
        inner.put16(4, 1)
        inner.put16(6, 15)
        inner.put64(8, timestamp)
        return inner + payload
    }

    @Test
    fun parsesFragmentHeaders() {
        val fragment = parseFragment(header(0x28, 3, 1, 1000))!!
        assertEquals(FrameKind.Video, fragment.kind)
        assertEquals(3, fragment.total)
        assertEquals(1, fragment.index)
        assertEquals(1000, fragment.length)
        assertTrue(fragment.valid)
        assertNull(parseFragment(ByteArray(12)))
        assertFalse(parseFragment(header(0x01, 2, 2, 10))!!.valid)
        assertFalse(parseFragment(header(0x01, 2, 0, 0))!!.valid)
        assertFalse(parseFragment(header(0x01, 2, 0, 20001))!!.valid)
        assertEquals(FrameKind.Audio, parseFragment(header(0x16, 1, 0, 272))!!.kind)
        assertEquals(FrameKind.Audio, parseFragment(header(0x18, 1, 0, 279))!!.kind)
        assertEquals(FrameKind.Other, parseFragment(header(0x5B, 1, 0, 8))!!.kind)
    }

    @Test
    fun assemblesFragmentsIntoOneFrame() {
        val body = ByteArray(2500) { (it % 251).toByte() }
        val whole = frame(body, id = 9, timestamp = 1234567890123L)
        val parts = listOf(whole.copyOfRange(0, 1000), whole.copyOfRange(1000, 2000), whole.copyOfRange(2000, whole.size))
        val assembler = Assembler()
        assertNull(assembler.add(Fragment(0x28, 3, 0, parts[0].size), parts[0]))
        assertNull(assembler.add(Fragment(0x28, 3, 1, parts[1].size), parts[1]))
        val done = assembler.add(Fragment(0x28, 3, 2, parts[2].size), parts[2])
        assertNotNull(done)
        done!!
        assertTrue(done.key)
        assertEquals(9L, done.id)
        assertEquals(15, done.rate)
        assertEquals(1234567890123L, done.timestamp)
        assertArrayEquals(body, done.payload)
    }

    @Test
    fun dropsFramesWithMissingFragments() {
        val whole = frame(ByteArray(300) { 1 })
        val assembler = Assembler()
        assertNull(assembler.add(Fragment(0x29, 3, 0, 100), whole.copyOfRange(0, 100)))
        assertNull(assembler.add(Fragment(0x29, 3, 2, 100), whole.copyOfRange(200, 300)))
        assertEquals(1L, assembler.dropped)
        val audio = frame(ByteArray(256) { 3 })
        val single = assembler.add(Fragment(0x16, 1, 0, audio.size), audio)
        assertNotNull(single)
        assertEquals(256, single!!.payload.size)
        assertFalse(single.key)
    }

    @Test
    fun audioAndVideoAssembleIndependently() {
        val video = frame(ByteArray(40) { 2 })
        val audio = frame(ByteArray(256) { 4 })
        val assembler = Assembler()
        assertNull(assembler.add(Fragment(0x29, 2, 0, 20), video.copyOfRange(0, 20)))
        assertNotNull(assembler.add(Fragment(0x18, 1, 0, audio.size), audio))
        val done = assembler.add(Fragment(0x29, 2, 1, video.size - 20), video.copyOfRange(20, video.size))
        assertNotNull(done)
        assertEquals(40, done!!.payload.size)
    }
}
