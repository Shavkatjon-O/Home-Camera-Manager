package uz.smartsurveillance.tv.control

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class OkPressTest {
    @Test
    fun shortPressOpensOnRelease() {
        val ok = OkPress()
        assertFalse(ok.down(repeatCount = 0, longPress = false))
        assertTrue(ok.up())
    }

    @Test
    fun longPressFlagOpensMenuOnceAndSuppressesRelease() {
        val ok = OkPress()
        assertFalse(ok.down(repeatCount = 0, longPress = false))
        assertTrue(ok.down(repeatCount = 1, longPress = true))
        assertFalse(ok.down(repeatCount = 2, longPress = true))
        assertFalse(ok.up())
    }

    @Test
    fun longPressByRepeatCount() {
        val ok = OkPress(longRepeats = 3)
        assertFalse(ok.down(repeatCount = 0, longPress = false))
        assertFalse(ok.down(repeatCount = 1, longPress = false))
        assertFalse(ok.down(repeatCount = 2, longPress = false))
        assertTrue(ok.down(repeatCount = 3, longPress = false))
        assertFalse(ok.up())
    }

    @Test
    fun strayReleaseDoesNothing() {
        val ok = OkPress()
        assertFalse(ok.up())
        assertFalse(ok.down(repeatCount = 5, longPress = true))
        assertFalse(ok.up())
    }
}
