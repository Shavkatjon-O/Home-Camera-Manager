package uz.home.cameras.tv.v380

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class AudioTest {
    @Test
    fun decodesAlaw() {
        assertEquals(8.toShort(), Alaw.sample(0xD5.toByte()))
        assertEquals((-8).toShort(), Alaw.sample(0x55.toByte()))
        assertEquals(32256.toShort(), Alaw.sample(0xAA.toByte()))
        assertEquals((-32256).toShort(), Alaw.sample(0x2A.toByte()))
        assertEquals((-5504).toShort(), Alaw.sample(0x00))
    }

    @Test
    fun decodesImaAdpcmBlocks() {
        val block = ByteArray(256)
        block.put16(0, 1000)
        block[2] = 10
        val samples = ImaAdpcm.decodeBlock(block, 0, block.size)
        assertEquals(505, samples.size)
        assertEquals(1000.toShort(), samples[0])
        val step = ImaAdpcm.decodeBlock(byteArrayOf(0, 0, 0, 0, 0x07), 0, 5)
        assertArrayEquals(shortArrayOf(0, 11, 13), step)
    }

    @Test
    fun parsesAdtsFromThePtzCamera() {
        val header = Adts.parse(hexBytes("fff96c4020fffc01"))!!
        assertEquals(2, header.objectType)
        assertEquals(8000, header.sampleRate)
        assertEquals(1, header.channels)
        assertEquals(7, header.headerSize)
        assertEquals(263, header.frameSize)
        assertEquals("1588", header.config().hex())
        assertNull(Adts.parse(hexBytes("0000000000000000")))
    }
}
