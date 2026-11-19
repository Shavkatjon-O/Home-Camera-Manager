package uz.home.cameras.tv.ui

import android.opengl.GLSurfaceView
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.viewinterop.AndroidView
import uz.home.cameras.tv.camera.Store
import uz.home.cameras.tv.wall.Wall

enum class Screen { Wall, Settings, Diagnostics }

@Composable
fun App(wall: Wall, store: Store, video: GLSurfaceView) {
    var screen by remember { mutableStateOf(Screen.Wall) }
    var menu by remember { mutableStateOf(false) }
    var focus by remember { mutableIntStateOf(0) }
    val plan by wall.plan.collectAsState()
    val scene by wall.scene.collectAsState()
    val feeds by wall.feeds.collectAsState()
    val full by wall.full.collectAsState()

    CamerasTheme {
        Box(Modifier.fillMaxSize().background(Color.Black)) {
            AndroidView(factory = { video }, modifier = Modifier.fillMaxSize())
            if (screen == Screen.Wall) {
                val slot = full
                val item = slot?.let { plan.slots.getOrNull(it) }
                if (slot != null && item != null) {
                    FullOverlay(
                        wall = wall,
                        slot = slot,
                        item = item,
                        feed = feeds[item.camera.id],
                        active = !menu,
                        onMenu = { menu = true },
                    )
                } else {
                    GridOverlay(
                        plan = plan,
                        scene = scene,
                        feeds = feeds,
                        focus = focus,
                        active = !menu,
                        onFocus = { focus = it },
                        onOpen = {
                            focus = it
                            wall.open(it)
                        },
                        onMenu = { menu = true },
                    )
                }
            }
            when (screen) {
                Screen.Settings -> SettingsScreen(wall, store) { screen = Screen.Wall }
                Screen.Diagnostics -> DiagnosticsScreen(wall) { screen = Screen.Wall }
                Screen.Wall -> Unit
            }
            if (menu) {
                MenuOverlay(
                    onSettings = {
                        menu = false
                        screen = Screen.Settings
                    },
                    onDiagnostics = {
                        menu = false
                        screen = Screen.Diagnostics
                    },
                    onReload = {
                        menu = false
                        wall.reload()
                    },
                    onClose = { menu = false },
                )
            }
        }
    }
}
