package uz.home.cameras.tv.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import uz.home.cameras.tv.data.Settings
import uz.home.cameras.tv.player.LivePlayer
import uz.home.cameras.tv.player.Viewer

enum class Screen { Setup, Pairing, Viewer }

@Composable
fun App(settings: Settings, live: LivePlayer, viewer: Viewer, screen: MutableState<Screen>) {
    var server by remember { mutableStateOf(settings.server) }
    CamerasTheme {
        Box(Modifier.fillMaxSize().background(Color.Black)) {
            when (screen.value) {
                Screen.Setup -> SetupScreen(
                    initial = server,
                    canCancel = settings.token != null,
                    onContinue = {
                        server = it
                        screen.value = Screen.Pairing
                    },
                    onCancel = {
                        server = settings.server
                        screen.value = Screen.Viewer
                    },
                )
                Screen.Pairing -> PairingScreen(
                    server = server,
                    onPaired = { token ->
                        settings.server = server
                        settings.token = token
                        screen.value = Screen.Viewer
                    },
                    onBack = { screen.value = Screen.Setup },
                )
                Screen.Viewer -> ViewerScreen(
                    live = live,
                    viewer = viewer,
                    server = settings.server,
                    onServer = {
                        server = settings.server
                        screen.value = Screen.Setup
                    },
                )
            }
        }
    }
}
