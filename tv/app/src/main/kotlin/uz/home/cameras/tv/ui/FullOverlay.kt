package uz.home.cameras.tv.ui

import android.content.Context
import android.media.AudioManager
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.platform.LocalContext
import kotlinx.coroutines.delay
import uz.home.cameras.tv.control.Key
import uz.home.cameras.tv.control.OkPress
import uz.home.cameras.tv.control.TileAction
import uz.home.cameras.tv.control.keyOf
import uz.home.cameras.tv.control.tileAction
import uz.home.cameras.tv.stream.Feed
import uz.home.cameras.tv.stream.label
import uz.home.cameras.tv.wall.Wall
import uz.home.cameras.tv.wall.WallItem

@Composable
fun FullOverlay(wall: Wall, slot: Int, item: WallItem, feed: Feed?, active: Boolean, onMenu: () -> Unit) {
    val context = LocalContext.current
    val audioManager = remember { context.getSystemService(Context.AUDIO_SERVICE) as AudioManager }
    val requester = remember { FocusRequester() }
    val ok = remember { OkPress() }
    val muted by wall.muted.collectAsState()
    val state = feed?.state?.collectAsState()?.value
    val hasAudio = feed?.hasAudio?.collectAsState()?.value ?: false
    var pulse by remember { mutableIntStateOf(0) }
    var label by remember { mutableStateOf(true) }
    var hint by remember { mutableStateOf(item.camera.ptz) }
    var systemMuted by remember { mutableStateOf(false) }
    val ptz = item.camera.ptz

    LaunchedEffect(active) {
        if (active) requester.requestFocus() else wall.stopMove()
    }
    LaunchedEffect(slot, pulse) {
        label = true
        delay(LABEL_MS)
        label = false
    }
    LaunchedEffect(slot) {
        hint = ptz
        delay(HINT_MS)
        hint = false
    }
    LaunchedEffect(Unit) {
        var volume = -1
        while (true) {
            val level = runCatching { audioManager.getStreamVolume(AudioManager.STREAM_MUSIC) }.getOrDefault(0)
            val mute = runCatching { audioManager.isStreamMute(AudioManager.STREAM_MUSIC) }.getOrDefault(false) || level == 0
            if (volume >= 0 && (mute != systemMuted || level != volume)) pulse += 1
            systemMuted = mute
            volume = level
            delay(VOLUME_POLL_MS)
        }
    }
    DisposableEffect(slot) {
        onDispose { wall.stopMove() }
    }
    BackHandler(enabled = active) { wall.back() }

    Box(
        Modifier
            .fillMaxSize()
            .focusRequester(requester)
            .focusable(enabled = active)
            .onKeyEvent { event ->
                val native = event.nativeKeyEvent
                val down = event.type == KeyEventType.KeyDown
                val key = keyOf(native.keyCode)
                if (key == Key.Center) {
                    if (down) {
                        if (ok.down(native.repeatCount, native.isLongPress)) {
                            wall.stopMove()
                            onMenu()
                        }
                    } else if (ok.up()) {
                        pulse += 1
                    }
                    return@onKeyEvent true
                }
                when (val action = tileAction(key, down, native.repeatCount, ptz)) {
                    is TileAction.Move -> {
                        wall.move(action.move)
                        true
                    }
                    TileAction.Stop -> {
                        wall.stopMove()
                        true
                    }
                    TileAction.Previous -> {
                        wall.step(-1)
                        true
                    }
                    TileAction.Next -> {
                        wall.step(1)
                        true
                    }
                    TileAction.Menu -> {
                        wall.stopMove()
                        onMenu()
                        true
                    }
                    TileAction.Mute -> {
                        wall.toggleMute()
                        pulse += 1
                        true
                    }
                    TileAction.Unmute -> {
                        if (muted) wall.setMuted(false)
                        pulse += 1
                        false
                    }
                    TileAction.Consumed -> true
                    TileAction.Ignored -> false
                }
            },
    ) {
        StatusText(state?.label(), Modifier.align(Alignment.Center))
        TileLabel(
            title = item.camera.name,
            lens = item.lensLabel,
            visible = label || hint,
            sound = if (hasAudio) !(muted || systemMuted) else null,
            hint = if (hint) "Arrows move the camera" else null,
            modifier = Modifier.align(Alignment.BottomStart),
        )
    }
}

private const val LABEL_MS = 3000L
private const val HINT_MS = 3000L
private const val VOLUME_POLL_MS = 300L
