package uz.smartsurveillance.tv.control

import org.junit.Assert.assertEquals
import org.junit.Test
import uz.smartsurveillance.tv.v380.PtzMove

class TileKeysTest {
    @Test
    fun ptzArrowsMoveOncePerHoldAndStopOnRelease() {
        assertEquals(TileAction.Move(PtzMove.Left), tileAction(Key.Left, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Consumed, tileAction(Key.Left, down = true, repeatCount = 4, ptz = true))
        assertEquals(TileAction.Stop, tileAction(Key.Left, down = false, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Move(PtzMove.Up), tileAction(Key.Up, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Move(PtzMove.Down), tileAction(Key.Down, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Move(PtzMove.Right), tileAction(Key.Right, down = true, repeatCount = 0, ptz = true))
    }

    @Test
    fun zoomKeysAreSwallowedBecauseTheCamerasHaveNoZoomCommand() {
        assertEquals(TileAction.Consumed, tileAction(Key.ZoomIn, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Consumed, tileAction(Key.ZoomOut, down = true, repeatCount = 0, ptz = false))
    }

    @Test
    fun otherCamerasStepWithLeftAndRight() {
        assertEquals(TileAction.Previous, tileAction(Key.Left, down = true, repeatCount = 0, ptz = false))
        assertEquals(TileAction.Next, tileAction(Key.Right, down = true, repeatCount = 0, ptz = false))
        assertEquals(TileAction.Consumed, tileAction(Key.Right, down = true, repeatCount = 1, ptz = false))
        assertEquals(TileAction.Consumed, tileAction(Key.Up, down = true, repeatCount = 0, ptz = false))
    }

    @Test
    fun muteAndVolume() {
        assertEquals(TileAction.Mute, tileAction(Key.Mute, down = true, repeatCount = 0, ptz = false))
        assertEquals(TileAction.Consumed, tileAction(Key.Mute, down = false, repeatCount = 0, ptz = false))
        assertEquals(TileAction.Unmute, tileAction(Key.VolumeUp, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Ignored, tileAction(Key.VolumeDown, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Menu, tileAction(Key.Menu, down = true, repeatCount = 0, ptz = true))
        assertEquals(TileAction.Ignored, tileAction(Key.Other, down = true, repeatCount = 0, ptz = true))
    }
}
