package uz.home.cameras.tv.control

import android.view.KeyEvent

enum class Key { Up, Down, Left, Right, Center, Menu, ZoomIn, ZoomOut, Mute, VolumeUp, VolumeDown, Other }

fun keyOf(code: Int): Key = when (code) {
    KeyEvent.KEYCODE_DPAD_UP -> Key.Up
    KeyEvent.KEYCODE_DPAD_DOWN -> Key.Down
    KeyEvent.KEYCODE_DPAD_LEFT -> Key.Left
    KeyEvent.KEYCODE_DPAD_RIGHT -> Key.Right
    KeyEvent.KEYCODE_DPAD_CENTER,
    KeyEvent.KEYCODE_ENTER,
    KeyEvent.KEYCODE_NUMPAD_ENTER,
    KeyEvent.KEYCODE_BUTTON_A -> Key.Center
    KeyEvent.KEYCODE_MENU -> Key.Menu
    KeyEvent.KEYCODE_CHANNEL_UP,
    KeyEvent.KEYCODE_MEDIA_FAST_FORWARD,
    KeyEvent.KEYCODE_ZOOM_IN -> Key.ZoomIn
    KeyEvent.KEYCODE_CHANNEL_DOWN,
    KeyEvent.KEYCODE_MEDIA_REWIND,
    KeyEvent.KEYCODE_ZOOM_OUT -> Key.ZoomOut
    KeyEvent.KEYCODE_VOLUME_MUTE,
    KeyEvent.KEYCODE_MUTE -> Key.Mute
    KeyEvent.KEYCODE_VOLUME_UP -> Key.VolumeUp
    KeyEvent.KEYCODE_VOLUME_DOWN -> Key.VolumeDown
    else -> Key.Other
}
