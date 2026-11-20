package uz.smartsurveillance.tv.v380

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class SpsTest {
    @Test
    fun readsTheSizesTheCamerasSend() {
        val sd = "42010101400000030090000003000003005aa0050200b459e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104"
        val hd = "420101014000000300900000030000030096a0012020028859e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104"
        val ptz2 = "420101014000000300900000030000030096a003c080087167a5b91295cd404080b8400000030040000003039403ff784000b71a0000895457c20104"
        assertEquals(VideoSize(640, 720), Sps.hevcSize(hexBytes(sd)))
        assertEquals(VideoSize(2304, 2592), Sps.hevcSize(hexBytes(hd)))
        assertEquals(VideoSize(1920, 2160), Sps.hevcSize(hexBytes(ptz2)))
    }

    @Test
    fun removesEmulationPrevention() {
        assertArrayEquals(byteArrayOf(0, 0, 1, 0, 0, 2), Sps.unescape(byteArrayOf(0, 0, 3, 1, 0, 0, 3, 2)))
        assertNull(Sps.hevcSize(byteArrayOf(0x42, 0x01)))
    }
}

class LowLatencyTest {
    private val cameras = listOf(
        "42010101400000030090000003000003005aa0050200b459e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104",
        "420101014000000300900000030000030096a0012020028859e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104",
        "420101014000000300900000030000030096a003c080087167a5b91295cd404080b8400000030040000003039403ff784000b71a0000895457c20104",
    )

    @Test
    fun clearsTheReorderDelayAndKeepsTheRest() {
        for (hex in cameras) {
            val sps = hexBytes(hex)
            assertEquals(listOf(1), Sps.hevcReorder(sps))
            val patched = Sps.hevcLowLatency(sps)!!
            assertEquals(listOf(0), Sps.hevcReorder(patched))
            assertEquals(Sps.hevcSize(sps), Sps.hevcSize(patched))
            assertNull(Sps.hevcLowLatency(patched))
            val unescaped = Sps.unescape(patched)
            assertArrayEquals(patched, Sps.escape(unescaped))
        }
    }

    @Test
    fun escapesStartCodeLookalikes() {
        assertArrayEquals(byteArrayOf(0, 0, 3, 1, 0, 0, 3, 0), Sps.escape(byteArrayOf(0, 0, 1, 0, 0, 0)))
    }
}
