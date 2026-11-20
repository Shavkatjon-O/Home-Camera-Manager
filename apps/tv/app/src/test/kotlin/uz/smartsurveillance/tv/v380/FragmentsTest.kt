package uz.smartsurveillance.tv.v380

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

class FragmentsTest {
    @Test
    fun headersFollowTheTable() {
        assertEquals(FragmentHeader(0x28, 3, 1, 1000), FragmentHeader.parse(unhex("7f2800030001 00e8030000 00".replace(" ", ""))))
        assertEquals(FragmentHeader(0x29, 1, 0, 4321), FragmentHeader.parse(unhex("7f2900010000 00e1100000 00".replace(" ", ""))))
        assertEquals(FragmentHeader(0x16, 1, 0, 272), FragmentHeader.parse(unhex("7f16000100000010010000 00".replace(" ", ""))))
        assertEquals(FragmentHeader(0x18, 1, 0, 279), FragmentHeader.parse(unhex("7f18000100000017010000 00".replace(" ", ""))))
        assertNull(FragmentHeader.parse(unhex("7f010002000200 0a00000000".replace(" ", ""))))
        assertNull(FragmentHeader.parse(unhex("7f0100020000000000000000")))
        assertNull(FragmentHeader.parse(unhex("7f010002000000214e000000")))
        assertNull(FragmentHeader.parse(ByteArray(12)))
        assertEquals("7f2800030001 00e8030000 00".replace(" ", ""), FragmentHeader.build(0x28, 3, 1, 1000).hex())
    }

    @Test
    fun frameHeaderMatchesTheTranscript() {
        assertEquals(
            "010000000000 0f00 0068e5cf8b010000".replace(" ", ""),
            FrameHeader.build(1, 0, 15, 1700000000000).hex(),
        )
        assertEquals(FrameHeader(9, 0, 15, 1234567890123), FrameHeader.parse(FrameHeader.build(9, 0, 15, 1234567890123)))
    }

    private val frame = FrameHeader.build(9, 0, 15, 1234567890123) + ByteArray(2500) { it.toByte() }

    private fun piece(from: Int, until: Int) = frame.copyOfRange(from, until + 1)

    @Test
    fun threeFragmentsInOrderMakeOneFrame() {
        val r = Reassembler()
        assertNull(r.push(FragmentHeader(0x28, 3, 0, 1000), piece(0, 999)))
        assertNull(r.push(FragmentHeader(0x28, 3, 1, 1000), piece(1000, 1999)))
        val done = r.push(FragmentHeader(0x28, 3, 2, 516), piece(2000, 2515))
        assertNotNull(done)
        assertEquals(frame.copyOfRange(16, 2516).hex(), done!!.data.copyOfRange(16, done.data.size).hex())
        assertEquals(0, r.dropped)
    }

    @Test
    fun aGapDropsTheFrameAndTheNextOneStartsClean() {
        val r = Reassembler()
        assertNull(r.push(FragmentHeader(0x29, 3, 0, 100), piece(0, 99)))
        assertNull(r.push(FragmentHeader(0x29, 3, 2, 100), piece(200, 299)))
        val done = r.push(FragmentHeader(0x29, 1, 0, 116), piece(0, 115))
        assertEquals(100, done!!.data.size - 16)
        assertEquals(1, r.dropped)
    }

    @Test
    fun aChangedCountDropsTheFrame() {
        val r = Reassembler()
        assertNull(r.push(FragmentHeader(0x29, 2, 0, 50), piece(0, 49)))
        assertNull(r.push(FragmentHeader(0x29, 3, 1, 50), piece(50, 99)))
        assertEquals(1, r.dropped)
    }

    @Test
    fun framesShorterThanTheHeaderAreDiscarded() {
        val r = Reassembler()
        assertNull(r.push(FragmentHeader(0x29, 1, 0, 10), piece(0, 9)))
        assertEquals(0, r.dropped)
    }

    @Test
    fun repeatedAndReorderedFragmentsDropTheFrame() {
        val repeated = Reassembler()
        repeated.push(FragmentHeader(0x28, 3, 0, 1000), piece(0, 999))
        repeated.push(FragmentHeader(0x28, 3, 1, 1000), piece(1000, 1999))
        assertNull(repeated.push(FragmentHeader(0x28, 3, 1, 1000), piece(1000, 1999)))
        assertNull(repeated.push(FragmentHeader(0x28, 3, 2, 516), piece(2000, 2515)))
        assertEquals(1, repeated.dropped)
        val reordered = Reassembler()
        reordered.push(FragmentHeader(0x28, 3, 0, 1000), piece(0, 999))
        assertNull(reordered.push(FragmentHeader(0x28, 3, 2, 516), piece(2000, 2515)))
        assertNull(reordered.push(FragmentHeader(0x28, 3, 1, 1000), piece(1000, 1999)))
        assertEquals(1, reordered.dropped)
    }

    @Test
    fun audioBetweenVideoFragmentsKeepsBothFrames() {
        val r = Reassembler()
        val audio = FrameHeader.build(3, 0, 0, 0) + ByteArray(256)
        assertNull(r.push(FragmentHeader(0x28, 2, 0, 1000), piece(0, 999)))
        assertEquals(0x16, r.push(FragmentHeader(0x16, 1, 0, audio.size), audio)!!.type)
        assertEquals(0x28, r.push(FragmentHeader(0x28, 2, 1, 1516), piece(1000, 2515))!!.type)
        assertNull(r.push(FragmentHeader(0x5B, 1, 0, 8), ByteArray(8)))
        assertEquals(0, r.dropped)
    }

    @Test
    fun aNewFirstFragmentDiscardsTheUnfinishedFrame() {
        val r = Reassembler()
        r.push(FragmentHeader(0x28, 3, 0, 1000), piece(0, 999))
        val done = r.push(FragmentHeader(0x29, 1, 0, 116), piece(0, 115))
        assertEquals(0x29, done!!.type)
        assertEquals(1, r.dropped)
    }

    @Test
    fun joiningInsideAFrameCountsOneDrop() {
        val r = Reassembler()
        assertNull(r.push(FragmentHeader(0x28, 4, 2, 10), ByteArray(10)))
        assertNull(r.push(FragmentHeader(0x28, 4, 3, 10), ByteArray(10)))
        assertEquals(1, r.dropped)
    }
}
