package uz.home.cameras.tv

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.lifecycleScope
import uz.home.cameras.tv.data.Settings
import uz.home.cameras.tv.player.LivePlayer
import uz.home.cameras.tv.player.Viewer
import uz.home.cameras.tv.ui.App
import uz.home.cameras.tv.ui.Screen

class MainActivity : ComponentActivity() {
    private lateinit var live: LivePlayer

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val settings = Settings(this)
        live = LivePlayer(this)
        val screen = mutableStateOf(if (settings.token != null) Screen.Viewer else Screen.Setup)
        val viewer = Viewer(this, settings, live, lifecycleScope) { screen.value = Screen.Pairing }
        setContent { App(settings, live, viewer, screen) }
    }

    override fun onDestroy() {
        live.release()
        super.onDestroy()
    }
}
