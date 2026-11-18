package uz.home.cameras.tv.ui

import android.view.LayoutInflater
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import androidx.media3.ui.PlayerView
import uz.home.cameras.tv.R
import uz.home.cameras.tv.player.LivePlayer

@Composable
fun PlayerSurface(live: LivePlayer, modifier: Modifier = Modifier) {
    val playing by live.playing.collectAsState()
    AndroidView(
        factory = { context ->
            (LayoutInflater.from(context).inflate(R.layout.player_view, null) as PlayerView).also {
                it.player = live.player
            }
        },
        update = { it.keepScreenOn = playing },
        onRelease = { it.player = null },
        modifier = modifier.fillMaxSize(),
    )
}
