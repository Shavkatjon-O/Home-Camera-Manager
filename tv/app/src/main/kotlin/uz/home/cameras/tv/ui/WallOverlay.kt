package uz.home.cameras.tv.ui

import androidx.compose.foundation.border
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
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
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import uz.home.cameras.tv.control.Key
import uz.home.cameras.tv.control.OkPress
import uz.home.cameras.tv.control.WallGrid
import uz.home.cameras.tv.control.keyOf
import uz.home.cameras.tv.data.TvConfig

@Composable
fun WallOverlay(
    config: TvConfig?,
    aspect: Float,
    focus: Int,
    active: Boolean,
    onFocus: (Int) -> Unit,
    onOpen: (Int) -> Unit,
    onMenu: () -> Unit,
) {
    val grid = remember(config) {
        WallGrid(config?.wall?.cols ?: 1, config?.wall?.rows ?: 1, config?.tiles?.map { it.index } ?: emptyList())
    }
    val focused = if (grid.contains(focus)) focus else grid.first ?: -1
    val requester = remember { FocusRequester() }
    val ok = remember { OkPress() }
    var pulse by remember { mutableIntStateOf(0) }
    var outline by remember { mutableStateOf(true) }
    var label by remember { mutableStateOf(true) }

    LaunchedEffect(active) { if (active) requester.requestFocus() }
    LaunchedEffect(pulse, focused) {
        outline = true
        label = true
        delay(LABEL_MS)
        label = false
        delay(OUTLINE_MS - LABEL_MS)
        outline = false
    }

    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        BoxWithConstraints(
            Modifier
                .aspectRatio(aspect)
                .focusRequester(requester)
                .focusable(enabled = active)
                .onKeyEvent { event ->
                    val native = event.nativeKeyEvent
                    val down = event.type == KeyEventType.KeyDown
                    when (val key = keyOf(native.keyCode)) {
                        Key.Up, Key.Down, Key.Left, Key.Right -> {
                            if (down) {
                                if (outline && focused >= 0) onFocus(grid.move(focused, key))
                                pulse += 1
                            }
                            true
                        }
                        Key.Center -> {
                            if (down) {
                                if (ok.down(native.repeatCount, native.isLongPress)) onMenu()
                            } else if (ok.up() && focused >= 0) {
                                onOpen(focused)
                            }
                            true
                        }
                        Key.Menu -> {
                            if (down && native.repeatCount == 0) onMenu()
                            true
                        }
                        else -> false
                    }
                },
        ) {
            val tile = config?.tiles?.firstOrNull { it.index == focused }
            if (outline && tile != null) {
                val width = maxWidth / grid.cols
                val height = maxHeight / grid.rows
                Box(
                    Modifier
                        .offset(x = width * grid.col(focused), y = height * grid.row(focused))
                        .size(width, height)
                        .border(2.dp, Outline),
                ) {
                    TileLabel(tile = tile, visible = label, modifier = Modifier.align(Alignment.BottomStart))
                }
            }
        }
    }
}

private const val LABEL_MS = 2500L
private const val OUTLINE_MS = 6000L
