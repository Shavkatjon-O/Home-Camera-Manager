package uz.smartsurveillance.tv.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.border
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Text
import uz.smartsurveillance.tv.control.Key
import uz.smartsurveillance.tv.control.keyOf

@Composable
fun AddressField(value: String, invalid: Boolean, onSubmit: (String) -> Unit, modifier: Modifier = Modifier) {
    var editing by remember { mutableStateOf(false) }
    var focused by remember { mutableStateOf(false) }
    var returning by remember { mutableStateOf(false) }
    var field by remember(value, editing) { mutableStateOf(TextFieldValue(value, TextRange(value.length))) }
    val editor = remember { FocusRequester() }
    val display = remember { FocusRequester() }
    val style = TextStyle(color = Color.White, fontSize = 18.sp)
    val frame = Modifier
        .border(2.dp, if (focused || editing) Color.White else Color(0xFF444444), RoundedCornerShape(8.dp))
        .padding(horizontal = 14.dp, vertical = 10.dp)

    fun finish(submit: Boolean) {
        if (submit) onSubmit(field.text)
        editing = false
        returning = true
    }

    if (editing) {
        BackHandler { finish(submit = false) }
        LaunchedEffect(Unit) { editor.requestFocus() }
        BasicTextField(
            value = field,
            onValueChange = { field = it },
            singleLine = true,
            textStyle = style,
            cursorBrush = SolidColor(Color.White),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Uri, imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = { finish(submit = true) }),
            modifier = modifier.focusRequester(editor).then(frame),
        )
    } else {
        LaunchedEffect(returning) {
            if (returning) {
                display.requestFocus()
                returning = false
            }
        }
        Box(
            modifier
                .focusRequester(display)
                .onFocusChanged { focused = it.isFocused }
                .focusable()
                .onKeyEvent { event ->
                    if (keyOf(event.nativeKeyEvent.keyCode) == Key.Center) {
                        if (event.type == KeyEventType.KeyUp) editing = true
                        true
                    } else {
                        false
                    }
                }
                .then(frame),
        ) {
            Text(value, style = style, color = if (invalid) Color(0xFFE57373) else Color.White)
        }
    }
}
