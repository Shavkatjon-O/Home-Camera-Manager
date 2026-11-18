package uz.home.cameras.tv.data

import android.content.Context
import androidx.core.content.edit

class Settings(context: Context) {
    private val prefs = context.getSharedPreferences("tv", Context.MODE_PRIVATE)

    var server: String
        get() = prefs.getString("server", null) ?: DEFAULT_SERVER
        set(value) = prefs.edit { putString("server", value) }

    var token: String?
        get() = prefs.getString("token", null)
        set(value) = prefs.edit { if (value == null) remove("token") else putString("token", value) }
}
