package uz.smartsurveillance.tv.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.tv.material3.MaterialTheme
import androidx.tv.material3.darkColorScheme

val Muted = Color(0xFF9A9A9A)
val Panel = Color(0xE6141414)
val Outline = Color(0xD9FFFFFF)

@Composable
fun CamerasTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = darkColorScheme(), content = content)
}
