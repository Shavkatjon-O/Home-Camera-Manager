package uz.home.cameras.tv.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.input.key.type
import kotlinx.coroutines.delay
import uz.home.cameras.tv.control.Key
import uz.home.cameras.tv.control.OkPress
import uz.home.cameras.tv.control.TileAction
import uz.home.cameras.tv.control.keyOf
import uz.home.cameras.tv.control.neighbour
import uz.home.cameras.tv.control.tileAction
import uz.home.cameras.tv.data.PtzMove
import uz.home.cameras.tv.data.TvConfig

@Composable
fun TileOverlay(
    config: TvConfig?,
    index: Int,
    active: Boolean,
    onSwitch: (Int) -> Unit,
    onPtz: (String, PtzMove?) -> Unit,
    onBack: () -> Unit,
    onMenu: () -> Unit,
) {
    val tile = config?.tiles?.firstOrNull { it.index == index }
    val indexes = config?.tiles?.map { it.index } ?: emptyList()
    val requester = remember { FocusRequester() }
    val ok = remember { OkPress() }
    var pulse by remember { mutableIntStateOf(0) }
    var label by remember { mutableStateOf(true) }
    var moving by remember { mutableStateOf<String?>(null) }
    val ptz by rememberUpdatedState(onPtz)

    fun stopMoving() {
        moving?.let { ptz(it, null) }
        moving = null
    }

    LaunchedEffect(active) {
        if (active) requester.requestFocus() else stopMoving()
    }
    LaunchedEffect(index, pulse) {
        label = true
        delay(LABEL_MS)
        label = false
    }
    DisposableEffect(index) {
        onDispose { stopMoving() }
    }
    BackHandler(enabled = active) {
        stopMoving()
        onBack()
    }

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
                        if (ok.down(native.repeatCount, native.isLongPress)) onMenu()
                    } else if (ok.up()) {
                        pulse += 1
                    }
                    return@onKeyEvent true
                }
                when (val action = tileAction(key, down, native.repeatCount, tile?.ptz == true)) {
                    is TileAction.Move -> {
                        tile?.let {
                            moving = it.cameraUuid
                            ptz(it.cameraUuid, action.move)
                        }
                        true
                    }
                    TileAction.Stop -> {
                        tile?.let { ptz(it.cameraUuid, null) }
                        moving = null
                        true
                    }
                    TileAction.Previous -> {
                        neighbour(indexes, index, -1)?.let { if (it != index) onSwitch(it) }
                        true
                    }
                    TileAction.Next -> {
                        neighbour(indexes, index, 1)?.let { if (it != index) onSwitch(it) }
                        true
                    }
                    TileAction.Menu -> {
                        stopMoving()
                        onMenu()
                        true
                    }
                    TileAction.Consumed -> true
                    TileAction.Ignored -> false
                }
            },
    ) {
        if (tile != null) {
            TileLabel(tile = tile, visible = label, modifier = Modifier.align(Alignment.BottomStart))
        }
    }
}

private const val LABEL_MS = 3000L
