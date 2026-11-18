package uz.home.cameras.tv.control

import android.view.KeyEvent
import org.junit.Assert.assertEquals
import org.junit.Test
import uz.home.cameras.tv.data.PtzMove

class TileKeysTest {
    @Test
    fun mapsRemoteKeys() {
        assertEquals(Key.Up, keyOf(KeyEvent.KEYCODE_DPAD_UP))
        assertEquals(Key.Center, keyOf(KeyEvent.KEYCODE_DPAD_CENTER))
        assertEquals(Key.Center, keyOf(KeyEvent.KEYCODE_ENTER))
        assertEquals(Key.Menu, keyOf(KeyEvent.KEYCODE_MENU))
        assertEquals(Key.ZoomIn, keyOf(KeyEvent.KEYCODE_CHANNEL_UP))
        assertEquals(Key.ZoomIn, keyOf(KeyEvent.KEYCODE_MEDIA_FAST_FORWARD))
        assertEquals(Key.ZoomOut, keyOf(KeyEvent.KEYCODE_CHANNEL_DOWN))
        assertEquals(Key.ZoomOut, keyOf(KeyEvent.KEYCODE_MEDIA_REWIND))
        assertEquals(Key.Other, keyOf(KeyEvent.KEYCODE_BACK))
    }

    @Test
    fun ptzArrowsMoveOnDownAndStopOnUp() {
        assertEquals(TileAction.Move(PtzMove(tilt = 0.5f)), tileAction(Key.Up, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Move(PtzMove(tilt = -0.5f)), tileAction(Key.Down, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Move(PtzMove(pan = -0.5f)), tileAction(Key.Left, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Move(PtzMove(pan = 0.5f)), tileAction(Key.Right, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Consumed, tileAction(Key.Right, down = true, repeatCount = 3, ptz = true))
        assertEquals(TileAction.Stop, tileAction(Key.Right, down = false, repeatCount = 0, ptz = true))
    }

    @Test
    fun ptzZoomKeys() {
        assertEquals(TileAction.Move(PtzMove(zoom = 0.5f)), tileAction(Key.ZoomIn, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Move(PtzMove(zoom = -0.5f)), tileAction(Key.ZoomOut, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Stop, tileAction(Key.ZoomOut, down = false, repeatCount = 0, ptz = true))
    }

    @Test
    fun fixedTileArrowsSwitchTiles() {
        assertEquals(TileAction.Previous, tileAction(Key.Left, down = true, repeatCount = 0, ptz = false))
        assertEquals(TileAction.Next, tileAction(Key.Right, down = true, repeatCount = 0, ptz = false))
        assertEquals(TileAction.Consumed, tileAction(Key.Right, down = true, repeatCount = 2, ptz = false))
        assertEquals(TileAction.Consumed, tileAction(Key.Right, down = false, repeatCount = 0, ptz = false))
        assertEquals(TileAction.Consumed, tileAction(Key.Up, down = true, repeatCount = 0, ptz = false))
        assertEquals(TileAction.Consumed, tileAction(Key.ZoomIn, down = true, repeatCount = 0, ptz = false))
    }

    @Test
    fun menuAndOtherKeys() {
        assertEquals(TileAction.Menu, tileAction(Key.Menu, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Consumed, tileAction(Key.Menu, down = false, repeatCount = 0, ptz = false))
        assertEquals(TileAction.Ignored, tileAction(Key.Other, down = true, repeatCount = 0, ptz = false))
    }

    @Test
    fun neighbourWraps() {
        val indexes = listOf(0, 1, 2, 4)
        assertEquals(1, neighbour(indexes, 0, 1))
        assertEquals(0, neighbour(indexes, 4, 1))
        assertEquals(4, neighbour(indexes, 0, -1))
        assertEquals(0, neighbour(indexes, 3, 1))
        assertEquals(null, neighbour(emptyList(), 0, 1))
    }
}
