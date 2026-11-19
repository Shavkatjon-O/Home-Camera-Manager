package uz.home.cameras.tv.render

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Test

class GeometryTest {
    @Test
    fun letterboxesInsideTheCell() {
        assertEquals(Box(0f, 90f, 640f, 360f), Geometry.fit(Box(0f, 0f, 640f, 540f), 16f / 9f))
        assertEquals(Box(240f, 0f, 1440f, 1080f), Geometry.fit(Box(0f, 0f, 1920f, 1080f), 4f / 3f))
        assertEquals(Box(0f, 90f, 640f, 360f), Geometry.fit(Box(0f, 0f, 640f, 540f), Float.NaN))
    }

    @Test
    fun lensAspectSplitsStackedFrames() {
        assertEquals(16f / 9f, Geometry.lensAspect(2304, 2592, 2), 0.001f)
        assertEquals(16f / 9f, Geometry.lensAspect(640, 720, 2), 0.001f)
        assertEquals(16f / 9f, Geometry.lensAspect(768, 432, 1), 0.001f)
    }

    @Test
    fun lensesMapToTextureHalves() {
        assertEquals(0f to 1f, Geometry.lensRange(0, 1))
        assertEquals(0.5f to 1f, Geometry.lensRange(0, 2))
        assertEquals(0f to 0.5f, Geometry.lensRange(1, 2))
    }

    @Test
    fun quadCoversTheRectInClipSpace() {
        val quad = Geometry.quad(Box(0f, 0f, 960f, 540f), 1920f, 1080f, lens = 1, lenses = 2)
        assertArrayEquals(
            floatArrayOf(
                -1f, 0f, 0f, 0f,
                0f, 0f, 1f, 0f,
                -1f, 1f, 0f, 0.5f,
                0f, 1f, 1f, 0.5f,
            ),
            quad,
            0.0001f,
        )
    }
}
