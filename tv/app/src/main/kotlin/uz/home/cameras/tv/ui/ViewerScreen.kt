package uz.home.cameras.tv.ui

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
import androidx.lifecycle.compose.LifecycleStartEffect
import uz.home.cameras.tv.player.LivePlayer
import uz.home.cameras.tv.player.Target
import uz.home.cameras.tv.player.Viewer

@Composable
fun ViewerScreen(live: LivePlayer, viewer: Viewer, server: String, onServer: () -> Unit) {
    val config by viewer.config.collectAsState()
    val target by viewer.target.collectAsState()
    val status by viewer.status.collectAsState()
    val aspect by live.aspect.collectAsState()
    var menu by remember { mutableStateOf(false) }
    var wallFocus by remember { mutableIntStateOf(-1) }

    LifecycleStartEffect(viewer) {
        viewer.start()
        onStopOrDispose { viewer.stop() }
    }

    Box(Modifier.fillMaxSize().background(Color.Black)) {
        PlayerSurface(live)
        when (val current = target) {
            Target.Wall -> WallOverlay(
                config = config,
                aspect = aspect,
                focus = wallFocus,
                active = !menu,
                onFocus = { wallFocus = it },
                onOpen = {
                    wallFocus = it
                    viewer.show(Target.Tile(it))
                },
                onMenu = { menu = true },
            )
            is Target.Tile -> TileOverlay(
                config = config,
                index = current.index,
                active = !menu,
                onSwitch = { viewer.show(Target.Tile(it)) },
                onPtz = viewer::ptz,
                onBack = {
                    wallFocus = current.index
                    viewer.show(Target.Wall)
                },
                onMenu = { menu = true },
            )
        }
        StatusLine(status)
        if (menu) {
            MenuOverlay(
                server = server,
                onReload = {
                    menu = false
                    viewer.reload()
                },
                onServer = {
                    menu = false
                    onServer()
                },
                onClose = { menu = false },
            )
        }
    }
}
