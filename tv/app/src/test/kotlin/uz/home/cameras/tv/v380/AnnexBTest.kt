package uz.home.cameras.tv.v380

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class AnnexBTest {
    private val vps = byteArrayOf(0x40, 0x01, 0x0C, 0x01)
    private val sps = byteArrayOf(0x42, 0x01, 0x01, 0x01)
    private val pps = byteArrayOf(0x44, 0x01, 0xC1.toByte())
    private val idr = byteArrayOf(0x26, 0x01, 0xAF.toByte(), 0x00, 0x11)

    private fun stream(vararg nals: ByteArray): ByteArray = nals.fold(ByteArray(0)) { acc, nal -> acc + byteArrayOf(0, 0, 0, 1) + nal }

    @Test
    fun trimsLeadingBytesBeforeTheStartCode() {
        val data = byteArrayOf(9, 9, 0, 0, 0, 1, 0x40, 0x01)
        assertEquals(2, AnnexB.startCodeAt(data))
        assertArrayEquals(byteArrayOf(0, 0, 0, 1, 0x40, 0x01), AnnexB.trim(data))
        assertNull(AnnexB.trim(ByteArray(40) { 7 }))
        assertEquals(0, AnnexB.startCodeAt(byteArrayOf(0, 0, 1, 0x26)))
    }

    @Test
    fun findsHevcParameterSets() {
        val keyframe = stream(vps, sps, pps, idr)
        assertEquals(Codec.Hevc, AnnexB.codecOf(keyframe))
        val nals = AnnexB.nals(keyframe, Codec.Hevc)
        assertEquals(listOf(32, 33, 34, 19), nals.map { it.type })
        val sets = AnnexB.parameterSets(keyframe, Codec.Hevc)!!
        assertArrayEquals(vps, sets[0].bytes)
        assertArrayEquals(sps, sets[1].bytes)
        assertArrayEquals(pps, sets[2].bytes)
        assertNull(AnnexB.parameterSets(stream(idr), Codec.Hevc))
        assertArrayEquals(byteArrayOf(0, 0, 0, 1) + vps, AnnexB.withStartCode(vps))
    }

    @Test
    fun recognisesAvc() {
        val avc = stream(byteArrayOf(0x67, 0x42, 0x00, 0x1F), byteArrayOf(0x68, 0xCE.toByte()), byteArrayOf(0x65, 0x88.toByte()))
        assertEquals(Codec.Avc, AnnexB.codecOf(avc))
        assertEquals(listOf(7, 8), AnnexB.parameterSets(avc, Codec.Avc)!!.map { it.type })
    }
}
