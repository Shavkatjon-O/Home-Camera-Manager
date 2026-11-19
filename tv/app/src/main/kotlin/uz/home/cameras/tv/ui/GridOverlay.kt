package uz.home.cameras.tv.ui

import androidx.compose.foundation.border
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
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
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Text
import kotlinx.coroutines.delay
import uz.home.cameras.tv.control.Key
import uz.home.cameras.tv.control.OkPress
import uz.home.cameras.tv.control.WallGrid
import uz.home.cameras.tv.control.keyOf
import uz.home.cameras.tv.render.Box as Rect
import uz.home.cameras.tv.render.Geometry
import uz.home.cameras.tv.render.Scene
import uz.home.cameras.tv.stream.Feed
import uz.home.cameras.tv.stream.label
import uz.home.cameras.tv.wall.WallPlan

@Composable
fun GridOverlay(
    plan: WallPlan,
    scene: Scene,
    feeds: Map<String, Feed>,
    focus: Int,
    active: Boolean,
    onFocus: (Int) -> Unit,
    onOpen: (Int) -> Unit,
    onMenu: () -> Unit,
) {
    val grid = remember(plan) { WallGrid(plan.cols, plan.rows, plan.occupied) }
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

    BoxWithConstraints(
        Modifier
            .fillMaxSize()
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
        val width = maxWidth.value
        val height = maxHeight.value
        for (tile in scene.tiles) {
            key(tile.slot) {
                val rect = Geometry.fit(tile.cell.scale(width, height), tile.aspect)
                val feed = feeds[tile.cameraId]
                val state = feed?.state?.collectAsState()?.value
                Placed(rect) {
                    StatusText(state?.label(), Modifier.align(Alignment.Center))
                }
            }
        }
        val tile = scene.tiles.firstOrNull { it.slot == focused }
        val item = plan.slots.getOrNull(focused)
        if (outline && tile != null && item != null) {
            Placed(Geometry.fit(tile.cell.scale(width, height), tile.aspect), Modifier.border(2.dp, Outline)) {
                TileLabel(item.camera.name, item.lensLabel, visible = label, modifier = Modifier.align(Alignment.BottomStart))
            }
        }
        if (plan.occupied.isEmpty()) {
            Text(
                "No cameras enabled. Press Menu or hold OK for settings.",
                color = Muted,
                fontSize = 20.sp,
                modifier = Modifier.align(Alignment.Center),
            )
        }
    }
}

@Composable
fun Placed(rect: Rect, modifier: Modifier = Modifier, content: @Composable androidx.compose.foundation.layout.BoxScope.() -> Unit) {
    Box(
        Modifier
            .offset(x = Dp(rect.x), y = Dp(rect.y))
            .size(Dp(rect.w), Dp(rect.h))
            .then(modifier),
        content = content,
    )
}

private const val LABEL_MS = 2500L
private const val OUTLINE_MS = 6000L
