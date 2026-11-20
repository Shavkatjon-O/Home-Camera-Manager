package uz.smartsurveillance.tv.ui

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.Debug
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Text
import java.net.Inet4Address
import java.net.NetworkInterface
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import uz.smartsurveillance.tv.BuildConfig
import uz.smartsurveillance.tv.control.Key
import uz.smartsurveillance.tv.control.keyOf
import uz.smartsurveillance.tv.stream.Codecs
import uz.smartsurveillance.tv.stream.FeedState
import uz.smartsurveillance.tv.stream.label
import uz.smartsurveillance.tv.wall.Wall

@Composable
fun DiagnosticsScreen(wall: Wall, onClose: () -> Unit) {
    val context = LocalContext.current
    var report by remember { mutableStateOf(Report(emptyList(), emptyList())) }
    val scroll = rememberScrollState()
    val scope = rememberCoroutineScope()
    val requester = remember { FocusRequester() }
    LaunchedEffect(Unit) {
        requester.requestFocus()
        while (true) {
            report = buildReport(context, wall)
            delay(1000)
        }
    }
    BackHandler { onClose() }
    Box(
        Modifier
            .fillMaxSize()
            .background(Color(0xE60A0A0A))
            .focusRequester(requester)
            .focusable()
            .onKeyEvent { event ->
                if (event.type != KeyEventType.KeyDown) return@onKeyEvent false
                when (keyOf(event.nativeKeyEvent.keyCode)) {
                    Key.Down -> {
                        scope.launch { scroll.animateScrollTo(scroll.value + 240) }
                        true
                    }
                    Key.Up -> {
                        scope.launch { scroll.animateScrollTo(scroll.value - 240) }
                        true
                    }
                    Key.Center, Key.Menu -> {
                        onClose()
                        true
                    }
                    else -> false
                }
            },
    ) {
        Row(
            Modifier
                .fillMaxWidth()
                .padding(horizontal = 32.dp, vertical = 24.dp)
                .verticalScroll(scroll),
            horizontalArrangement = Arrangement.spacedBy(24.dp),
        ) {
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text("Diagnostics", color = Color.White, fontSize = 22.sp)
                report.left.forEach { Line(it) }
            }
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                report.right.forEach { Line(it) }
            }
        }
    }
}

@Composable
private fun Line(text: String) {
    val heading = text.startsWith("# ")
    Text(
        if (heading) text.removePrefix("# ") else text,
        color = if (heading) Color.White else Color(0xFFCCCCCC),
        fontSize = if (heading) 15.sp else 11.sp,
        fontFamily = if (heading) null else FontFamily.Monospace,
        modifier = if (heading) Modifier.padding(top = 8.dp) else Modifier,
    )
}

private data class Report(val left: List<String>, val right: List<String>)

private fun buildReport(context: Context, wall: Wall): Report {
    val now = System.currentTimeMillis()
    val left = ArrayList<String>()
    val feeds = wall.feeds.value
    left += "# Cameras"
    for (camera in wall.cameras.value) {
        val feed = feeds[camera.id]
        left += "# ${camera.name}  ${camera.address}"
        if (!camera.enabled) {
            left += "disabled"
            continue
        }
        if (feed == null) {
            left += "paused"
            continue
        }
        val state = feed.state.value
        val rates = feed.stats.sample(now)
        left += "state      ${if (state == FeedState.Playing) "Playing" else state.label()}  (${feed.spec.quality})"
        left += "stream     ${feed.stats.stream ?: "-"}"
        left += "video      ${feed.size.value?.let { "${it.width}x${it.height}" } ?: "-"}  %.1f fps  %.0f kbit/s".format(rates.fps, rates.kbps)
        left += "decoder    ${feed.stats.decoder ?: "-"}"
        left += "latency    ${feed.stats.latency ?: "-"}"
        feed.stats.startup?.let { left += "startup    $it" }
        if (feed.spec.audio) left += "audio      ${feed.stats.audio ?: "none received"}"
        feed.stats.error?.let { left += "last error $it" }
    }
    val right = ArrayList<String>()
    right += "# Device"
    right += "${Build.MANUFACTURER} ${Build.MODEL}, Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"
    right += "app ${BuildConfig.VERSION_NAME}, address ${address() ?: "no network"}"
    val activity = context.getSystemService(ActivityManager::class.java)
    val memory = ActivityManager.MemoryInfo().also { activity?.getMemoryInfo(it) }
    val pss = runCatching { Debug.MemoryInfo().also { Debug.getMemoryInfo(it) }.totalPss / 1024 }.getOrDefault(0)
    right += "app memory $pss MB PSS, device ${memory.availMem / 1048576} of ${memory.totalMem / 1048576} MB free${if (memory.lowMemory) ", LOW" else ""}"
    right += "decoders in use ${feeds.values.mapNotNull { it.stats.decoder }.groupingBy { it }.eachCount().entries.joinToString { "${it.key} x${it.value}" }.ifEmpty { "none" }}"
    right += "# Video decoders"
    for (codec in Codecs.all) {
        val kind = if (codec.hardware) "hw" else "sw"
        right += "${codec.mime.removePrefix("video/")} $kind ${codec.name}"
        right += "    max ${codec.maxInstances} instances, ${codec.maxWidth}x${codec.maxHeight}"
    }
    if (Codecs.all.isEmpty()) right += "none reported"
    right += "# Events"
    val events = wall.events.value
    if (events.isEmpty()) right += "none"
    events.reversed().forEach { right += it }
    right += "# Keys"
    right += "Up and Down scroll, OK or Back closes"
    return Report(left, right)
}

private fun address(): String? = runCatching {
    NetworkInterface.getNetworkInterfaces().toList()
        .filter { it.isUp && !it.isLoopback }
        .flatMap { it.inetAddresses.toList() }
        .firstOrNull { it is Inet4Address }
        ?.hostAddress
}.getOrNull()
