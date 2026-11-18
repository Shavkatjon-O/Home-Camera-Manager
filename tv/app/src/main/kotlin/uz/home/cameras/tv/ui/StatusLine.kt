package uz.home.cameras.tv.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Text

@Composable
fun StatusLine(status: String?) {
    if (status.isNullOrBlank()) return
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(status, color = Muted, fontSize = 18.sp)
    }
}
