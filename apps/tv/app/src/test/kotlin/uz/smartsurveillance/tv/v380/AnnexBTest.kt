package uz.smartsurveillance.tv.v380

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Test

class AnnexBTest {
    @Test
    fun alignmentFollowsTheTable() {
        assertEquals("00000001400102", AnnexB.align(unhex("ababcd00000001400102"))!!.hex())
        val three = unhex("00000140")
        assertSame(three, AnnexB.align(three))
        val four = unhex("0000000140")
        assertSame(four, AnnexB.align(four))
        assertEquals("00000140", AnnexB.align(counting(15, 1) + unhex("00000140"))!!.hex())
        assertEquals("0000000140", AnnexB.align(counting(14, 1) + unhex("0000000140"))!!.hex())
        assertNull(AnnexB.align(counting(16, 1) + unhex("0000000140")))
        assertNull(AnnexB.align(ByteArray(40) { 7 }))
    }

    @Test
    fun codecsAreIdentifiedFromParameterSets() {
        assertEquals(Codec.Hevc, AnnexB.codecOf(Transcript.keyUnit))
        assertEquals(listOf(32, 33, 34, 19), AnnexB.nals(Transcript.keyUnit, Codec.Hevc).map { it.type })
        val avc = unhex("0000000167 42001f 0000000168ce3c80 000000016588 84".replace(" ", ""))
        assertEquals(Codec.Avc, AnnexB.codecOf(avc))
        assertEquals(listOf(7, 8, 5), AnnexB.nals(avc, Codec.Avc).map { it.type })
        val bare = unhex("000000012601af")
        assertNull(AnnexB.codecOf(bare))
        assertEquals(listOf(19), AnnexB.nals(bare, Codec.Hevc).map { it.type })
    }

    @Test
    fun parameterSetsComeInDecoderOrder() {
        val sets = AnnexB.parameterSets(Transcript.keyUnit, Codec.Hevc)!!
        assertEquals(Transcript.vps.hex(), sets[0].bytes.hex())
        assertEquals(Transcript.subSps.hex(), sets[1].bytes.hex())
        assertEquals(Transcript.pps.hex(), sets[2].bytes.hex())
        assertNull(AnnexB.parameterSets(unhex("000000012601af"), Codec.Hevc))
        assertEquals("0000000142", AnnexB.withStartCode(byteArrayOf(0x42)).hex())
    }

    @Test
    fun transcriptAccessUnitsHaveTheirHashes() {
        assertEquals(405, Transcript.keyUnit.size)
        assertEquals("4fa878bcbf542199aa5f3fb8f6db637133a207ed0b97d7b8c99256f4d506d6a0", sha256(Transcript.keyUnit))
        val aligned = AnnexB.align(Transcript.nonKeySent)!!
        assertEquals(126, aligned.size)
        assertEquals("8991ae3d02173299355cca95fd82d716148b0792ae51bc99acd14b5ed62b7a8c", sha256(aligned))
    }
}
