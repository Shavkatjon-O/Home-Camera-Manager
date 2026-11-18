package uz.home.cameras.tv.ui

import android.os.Build
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.onPreviewKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Button
import androidx.tv.material3.Text
import uz.home.cameras.tv.BuildConfig
import uz.home.cameras.tv.control.Key
import uz.home.cameras.tv.control.keyOf

@Composable
fun MenuOverlay(server: String, onReload: () -> Unit, onServer: () -> Unit, onClose: () -> Unit) {
    var about by remember { mutableStateOf(false) }
    val first = remember { FocusRequester() }
    LaunchedEffect(Unit) { first.requestFocus() }
    BackHandler { if (about) about = false else onClose() }
    Box(
        Modifier
            .fillMaxSize()
            .background(Color(0x59000000))
            .onPreviewKeyEvent { event ->
                if (keyOf(event.nativeKeyEvent.keyCode) == Key.Menu) {
                    if (event.type == KeyEventType.KeyDown && event.nativeKeyEvent.repeatCount == 0) onClose()
                    true
                } else {
                    false
                }
            },
        contentAlignment = Alignment.CenterEnd,
    ) {
        Column(
            modifier = Modifier
                .padding(48.dp)
                .width(340.dp)
                .background(Panel, RoundedCornerShape(12.dp))
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Button(onClick = onReload, modifier = Modifier.fillMaxWidth().focusRequester(first)) {
                Text("Reload")
            }
            Button(onClick = onServer, modifier = Modifier.fillMaxWidth()) {
                Text("Server and pairing")
            }
            Button(onClick = { about = !about }, modifier = Modifier.fillMaxWidth()) {
                Text("About")
            }
            if (about) {
                Column(Modifier.padding(horizontal = 8.dp, vertical = 4.dp)) {
                    Text("Home cameras ${BuildConfig.VERSION_NAME}", color = Color.White, fontSize = 15.sp)
                    Text(server, color = Muted, fontSize = 14.sp)
                    Text(Build.MODEL ?: "", color = Muted, fontSize = 14.sp)
                }
            }
        }
    }
}
