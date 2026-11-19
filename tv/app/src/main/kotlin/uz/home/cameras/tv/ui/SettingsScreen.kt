package uz.home.cameras.tv.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Button
import androidx.tv.material3.Switch
import androidx.tv.material3.Text
import uz.home.cameras.tv.camera.Camera
import uz.home.cameras.tv.camera.Kind
import uz.home.cameras.tv.camera.Store
import uz.home.cameras.tv.wall.Wall

@Composable
fun SettingsScreen(wall: Wall, store: Store, onClose: () -> Unit) {
    val cameras by wall.cameras.collectAsState()
    val discovery by wall.discovery.collectAsState()
    val first = remember { FocusRequester() }
    LaunchedEffect(Unit) { first.requestFocus() }
    BackHandler { onClose() }
    Box(Modifier.fillMaxSize().background(Color(0xF20A0A0A)), contentAlignment = Alignment.TopCenter) {
        Column(
            modifier = Modifier
                .padding(horizontal = 32.dp, vertical = 24.dp)
                .widthIn(max = 860.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text("Settings", color = Color.White, fontSize = 24.sp)
            Text("Press OK on an address to change it, type it on the keyboard and confirm. Changes apply at once.", color = Muted, fontSize = 15.sp)
            cameras.forEachIndexed { index, camera ->
                CameraRow(
                    camera = camera,
                    modifier = if (index == 0) Modifier.focusRequester(first) else Modifier,
                    onAddress = { text ->
                        val parsed = Camera.parseAddress(text, camera.defaultPort)
                        if (parsed != null) {
                            store.setAddress(camera.id, parsed.first, parsed.second)
                            wall.applyCameras()
                        }
                        parsed != null
                    },
                    onEnabled = {
                        store.setEnabled(camera.id, it)
                        wall.applyCameras()
                    },
                )
            }
            Spacer(Modifier.height(8.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                Button(onClick = { wall.discover(auto = false) }) { Text("Find V380 cameras") }
                Button(onClick = {
                    store.reset()
                    wall.applyCameras()
                }) { Text("Reset to defaults") }
                Button(onClick = onClose) { Text("Done") }
            }
            discovery?.let { Text(it, color = Muted, fontSize = 15.sp) }
        }
    }
}

@Composable
private fun CameraRow(camera: Camera, modifier: Modifier, onAddress: (String) -> Boolean, onEnabled: (Boolean) -> Unit) {
    var invalid by remember(camera.address) { mutableStateOf(false) }
    Row(
        modifier = Modifier
            .background(Panel, RoundedCornerShape(10.dp))
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Column(Modifier.width(170.dp)) {
            Text(camera.name, color = Color.White, fontSize = 18.sp)
            Text(
                if (camera.kind == Kind.V380) "V380, device ${camera.deviceId}" else "RTSP",
                color = Muted,
                fontSize = 13.sp,
            )
        }
        Column(Modifier.width(300.dp)) {
            AddressField(
                value = camera.address,
                invalid = invalid,
                onSubmit = { text -> if (text.trim() != camera.address) invalid = !onAddress(text) },
                modifier = modifier.width(300.dp),
            )
            if (invalid) Text("Not a valid address", color = Color(0xFFE57373), fontSize = 13.sp)
        }
        Switch(checked = camera.enabled, onCheckedChange = onEnabled)
        Text(if (camera.enabled) "On" else "Off", color = Muted, fontSize = 15.sp)
    }
}
