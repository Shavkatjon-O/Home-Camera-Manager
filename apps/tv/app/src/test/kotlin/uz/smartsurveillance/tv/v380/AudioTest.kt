package uz.smartsurveillance.tv.v380

import java.nio.ByteBuffer
import java.nio.ByteOrder
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class AudioTest {
    @Test
    fun smallAdpcmBlockDecodes() {
        assertEquals(listOf<Short>(0, 11, 13), ImaAdpcm.decodeBlock(unhex("0000000007"), 0, 5).toList())
    }

    @Test
    fun transcriptAdpcmBlockDecodes() {
        val block = Transcript.adpcm
        assertEquals(256, block.size)
        assertEquals("425cb3f8eb562213057765810edf649f33f8e4f50cd6210370f4441c3c392ca8", sha256(block))
        val samples = ImaAdpcm.decodeBlock(block, 0, block.size)
        assertEquals(505, samples.size)
        assertEquals(listOf<Short>(1000, 1002, 1004, 1010, 1011, 1018, 1019, 1027), samples.take(8))
        assertEquals((-32768).toShort(), samples.last())
        val pcm = ByteBuffer.allocate(samples.size * 2).order(ByteOrder.LITTLE_ENDIAN)
        samples.forEach { pcm.putShort(it) }
        assertEquals("5afe464b1e3fe4ebc142904fb62c596a00a70445e1d66541a9835c83878d2232", sha256(pcm.array()))
    }

    @Test
    fun alawDecodes() {
        assertEquals(8, Alaw.sample(0xD5))
        assertEquals(-8, Alaw.sample(0x55))
        assertEquals(32256, Alaw.sample(0xAA))
        assertEquals(-32256, Alaw.sample(0x2A))
        assertEquals(-5504, Alaw.sample(0x00))
        assertEquals(5504, Alaw.sample(0x80))
        assertEquals(listOf<Short>(8, -8), Alaw.decode(unhex("00d555"), 1, 2).toList())
    }

    @Test
    fun adtsHeaderOfTheVersion31Camera() {
        val header = Adts.parse(Transcript.adts)!!
        assertEquals(2, header.objectType)
        assertEquals(11, header.rateIndex)
        assertEquals(8000, header.sampleRate)
        assertEquals(1, header.channels)
        assertEquals(7, header.headerSize)
        assertEquals(263, header.frameSize)
        assertEquals("1588", header.config().hex())
        assertEquals("d0cc0b3346a1cdb853081a9ba8995961f23f059a3df4f9a53c8e702de828dd6b", sha256(Transcript.adts))
        assertNull(Adts.parse(unhex("00f96c4020fffc")))
    }

    @Test
    fun transcriptAlawFrameHasItsHash() {
        assertEquals("448ebbc9e1a31220a2f3830c18eef61b9bd070e5084b7fa2a359fe729184c719", sha256(Transcript.alaw))
    }
}
