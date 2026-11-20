package uz.smartsurveillance.tv.v380

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class SpsTest {
    private class Case(val size: VideoSize, val bits: IntRange, val sps: String, val rewritten: String)

    private val cases = listOf(
        Case(
            VideoSize(640, 720),
            174..176,
            "42010101400000030090000003000003005aa0050200b459e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104",
            "42010101400000030090000003000003005aa0050200b459ebb91295cd404080b8400000030040000003039515ff7840fa01775f080410",
        ),
        Case(
            VideoSize(2304, 2592),
            182..184,
            "420101014000000300900000030000030096a0012020028859e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104",
            "420101014000000300900000030000030096a0012020028859ebb91295cd404080b8400000030040000003039515ff7840fa01775f080410",
        ),
        Case(
            VideoSize(1920, 2160),
            180..182,
            "420101014000000300900000030000030096a003c080087167a5b91295cd404080b8400000030040000003039403ff784000b71a0000895457c20104",
            "420101014000000300900000030000030096a003c080087167aee44a5735010202e10000030001000003000e500ffde10002dc68000225515f080410",
        ),
    )

    @Test
    fun sizesAndReorderFieldsFollowTheVectors() {
        for (case in cases) {
            val fields = Sps.hevc(unhex(case.sps))!!
            assertEquals(case.size, fields.size)
            assertEquals(case.size, Sps.hevcSize(unhex(case.sps)))
            assertEquals(listOf(case.bits), fields.reorder)
            assertEquals(listOf(1L), fields.reorderValues)
        }
    }

    @Test
    fun theRewriteDeclaresNoReordering() {
        for (case in cases) {
            val rewritten = Sps.hevcLowLatency(unhex(case.sps))!!
            assertEquals(case.rewritten, rewritten.hex())
            assertEquals(unhex(case.sps).size, rewritten.size)
            assertEquals(case.size, Sps.hevcSize(rewritten))
            assertEquals(listOf(0L), Sps.hevc(rewritten)!!.reorderValues)
            assertNull(Sps.hevcLowLatency(rewritten))
        }
    }

    @Test
    fun emulationPreventionWorksBothWays() {
        assertEquals("0000030100000300", Sps.insertEmulation(unhex("000001000000")).hex())
        assertEquals("000001000002", Sps.removeEmulation(unhex("0000030100000302")).hex())
    }

    @Test
    fun brokenSpsGivesNoSize() {
        assertNull(Sps.hevcSize(unhex("4201")))
        assertNull(Sps.hevcLowLatency(unhex("4201")))
    }

    @Test
    fun avcSizeComesFromItsSps() {
        val sps = BitWriter().apply {
            bits(0x67, 8)
            bits(66, 8)
            bits(0, 8)
            bits(31, 8)
            ue(0)
            ue(0)
            ue(0)
            ue(0)
            ue(1)
            bit(0)
            ue(39)
            ue(29)
            bit(1)
            bit(1)
            bit(1)
            ue(0)
            ue(0)
            ue(0)
            ue(4)
            bit(1)
        }.bytes()
        assertEquals(VideoSize(640, 472), Sps.avcSize(sps))
    }

    private fun BitWriter.ue(value: Int) {
        val code = value + 1
        val length = 32 - Integer.numberOfLeadingZeros(code)
        repeat(length - 1) { bit(0) }
        bits(code.toLong(), length)
    }
}
