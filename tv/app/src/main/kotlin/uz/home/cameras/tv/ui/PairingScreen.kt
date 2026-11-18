package uz.home.cameras.tv.ui

import android.os.Build
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Text
import uz.home.cameras.tv.data.Api
import uz.home.cameras.tv.pairing.PairingController

@Composable
fun PairingScreen(server: String, onPaired: (String) -> Unit, onBack: () -> Unit) {
    val controller = remember(server) { PairingController(Api(server), Build.MODEL?.takeIf { it.isNotBlank() } ?: "Android TV") }
    val state by controller.state.collectAsState()
    val paired by rememberUpdatedState(onPaired)
    LaunchedEffect(controller) { paired(controller.run()) }
    BackHandler { onBack() }
    Column(
        modifier = Modifier.fillMaxSize().padding(48.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("Pair this TV", color = Muted, fontSize = 22.sp)
        Spacer(Modifier.height(16.dp))
        Text(
            text = state.code ?: "------",
            color = if (state.code == null) Color(0xFF444444) else Color.White,
            fontSize = 120.sp,
            fontFamily = FontFamily.Monospace,
            fontWeight = FontWeight.Bold,
            letterSpacing = 16.sp,
        )
        Spacer(Modifier.height(16.dp))
        Text("Open Cameras, TV in the web app and enter this code", color = Color.White, fontSize = 24.sp)
        Spacer(Modifier.height(12.dp))
        Text(server, color = Muted, fontSize = 18.sp)
        Spacer(Modifier.height(24.dp))
        Text(state.status ?: "", color = Muted, fontSize = 16.sp)
    }
}
