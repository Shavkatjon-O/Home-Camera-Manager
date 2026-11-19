package uz.home.cameras.tv.control

import uz.home.cameras.tv.v380.PtzMove

sealed interface TileAction {
    data class Move(val move: PtzMove) : TileAction
    data object Stop : TileAction
    data object Previous : TileAction
    data object Next : TileAction
    data object Menu : TileAction
    data object Mute : TileAction
    data object Unmute : TileAction
    data object Consumed : TileAction
    data object Ignored : TileAction
}

fun tileAction(key: Key, down: Boolean, repeatCount: Int, ptz: Boolean): TileAction {
    val move = ptzMoveFor(key)
    if (ptz && move != null) {
        return when {
            !down -> TileAction.Stop
            repeatCount == 0 -> TileAction.Move(move)
            else -> TileAction.Consumed
        }
    }
    val first = down && repeatCount == 0
    return when (key) {
        Key.Left -> if (first) TileAction.Previous else TileAction.Consumed
        Key.Right -> if (first) TileAction.Next else TileAction.Consumed
        Key.Up, Key.Down, Key.ZoomIn, Key.ZoomOut -> TileAction.Consumed
        Key.Menu -> if (first) TileAction.Menu else TileAction.Consumed
        Key.Mute -> if (first) TileAction.Mute else TileAction.Consumed
        Key.VolumeUp -> if (first) TileAction.Unmute else TileAction.Ignored
        else -> TileAction.Ignored
    }
}

fun ptzMoveFor(key: Key): PtzMove? = when (key) {
    Key.Up -> PtzMove.Up
    Key.Down -> PtzMove.Down
    Key.Left -> PtzMove.Left
    Key.Right -> PtzMove.Right
    else -> null
}
