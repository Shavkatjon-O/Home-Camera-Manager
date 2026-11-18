package uz.home.cameras.tv.control

import uz.home.cameras.tv.data.PtzMove

sealed interface TileAction {
    data class Move(val move: PtzMove) : TileAction
    data object Stop : TileAction
    data object Previous : TileAction
    data object Next : TileAction
    data object Menu : TileAction
    data object Consumed : TileAction
    data object Ignored : TileAction
}

const val PTZ_SPEED = 0.5f

fun tileAction(key: Key, down: Boolean, repeatCount: Int, ptz: Boolean): TileAction {
    val move = ptzMoveFor(key)
    if (ptz && move != null) {
        return when {
            !down -> TileAction.Stop
            repeatCount == 0 -> TileAction.Move(move)
            else -> TileAction.Consumed
        }
    }
    return when (key) {
        Key.Left -> if (down && repeatCount == 0) TileAction.Previous else TileAction.Consumed
        Key.Right -> if (down && repeatCount == 0) TileAction.Next else TileAction.Consumed
        Key.Up, Key.Down, Key.ZoomIn, Key.ZoomOut -> TileAction.Consumed
        Key.Menu -> if (down && repeatCount == 0) TileAction.Menu else TileAction.Consumed
        else -> TileAction.Ignored
    }
}

fun ptzMoveFor(key: Key): PtzMove? = when (key) {
    Key.Up -> PtzMove(tilt = PTZ_SPEED)
    Key.Down -> PtzMove(tilt = -PTZ_SPEED)
    Key.Left -> PtzMove(pan = -PTZ_SPEED)
    Key.Right -> PtzMove(pan = PTZ_SPEED)
    Key.ZoomIn -> PtzMove(zoom = PTZ_SPEED)
    Key.ZoomOut -> PtzMove(zoom = -PTZ_SPEED)
    else -> null
}

fun neighbour(indexes: List<Int>, current: Int, step: Int): Int? {
    if (indexes.isEmpty()) return null
    val position = indexes.indexOf(current)
    if (position < 0) return indexes.first()
    return indexes[(position + step + indexes.size) % indexes.size]
}
