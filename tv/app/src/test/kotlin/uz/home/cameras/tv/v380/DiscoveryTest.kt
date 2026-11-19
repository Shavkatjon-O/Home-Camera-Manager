package uz.home.cameras.tv.v380

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class DiscoveryTest {
    @Test
    fun parsesSearchReplies() {
        val reply = "NVDEVRESULT^1^AA:BB:CC:DD:EE:FF^192.168.1.237^255.255.255.0^192.168.1.1^x^x^x^x^x^x^11223344^x"
        assertEquals(Found("11223344", "192.168.1.237", "AA:BB:CC:DD:EE:FF"), Discovery.parse(reply))
        assertNull(Discovery.parse("NVDEVSEARCH^100"))
        assertNull(Discovery.parse("NVDEVRESULT^1^2"))
    }
}
