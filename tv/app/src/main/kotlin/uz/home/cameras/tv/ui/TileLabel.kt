package uz.home.cameras.tv.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Text
import uz.home.cameras.tv.R

@Composable
fun TileLabel(
    title: String,
    lens: String?,
    visible: Boolean,
    modifier: Modifier = Modifier,
    sound: Boolean? = null,
    hint: String? = null,
) {
    AnimatedVisibility(
        visible = visible,
        enter = fadeIn(tween(150)),
        exit = fadeOut(tween(600)),
        modifier = modifier,
    ) {
        Column(
            modifier = Modifier
                .padding(12.dp)
                .background(Color(0x99000000), RoundedCornerShape(6.dp))
                .padding(horizontal = 10.dp, vertical = 6.dp),
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(title, color = Color.White, fontSize = 16.sp, maxLines = 1)
                lens?.let {
                    Text(it, color = Color(0x8CFFFFFF), fontSize = 14.sp, fontFamily = FontFamily.Monospace, maxLines = 1)
                }
                sound?.let {
                    Image(
                        painter = painterResource(if (it) R.drawable.ic_sound else R.drawable.ic_muted),
                        contentDescription = if (it) "Sound on" else "Muted",
                        modifier = Modifier.size(18.dp),
                    )
                }
            }
            hint?.let { Text(it, color = Muted, fontSize = 13.sp, maxLines = 1) }
        }
    }
}

@Composable
fun StatusText(text: String?, modifier: Modifier = Modifier) {
    if (text.isNullOrBlank()) return
    Text(
        text,
        color = Muted,
        fontSize = 15.sp,
        maxLines = 2,
        modifier = modifier
            .background(Color(0x80000000), RoundedCornerShape(6.dp))
            .padding(horizontal = 10.dp, vertical = 4.dp),
    )
}
