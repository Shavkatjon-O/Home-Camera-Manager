package uz.smartsurveillance.tv.camera

import android.content.Context
import androidx.core.content.edit
import uz.smartsurveillance.tv.BuildConfig

class Store(context: Context) {
    private val prefs = context.getSharedPreferences("cameras", Context.MODE_PRIVATE)

    val defaults: List<Camera> = Camera.parse(BuildConfig.CAMERAS)

    fun cameras(): List<Camera> = defaults.map { camera ->
        val host = prefs.getString("${camera.id}.host", null)
        val port = prefs.getInt("${camera.id}.port", camera.port)
        val enabled = prefs.getBoolean("${camera.id}.enabled", camera.enabled)
        camera.copy(host = host ?: camera.host, port = if (host == null) camera.port else port, enabled = enabled)
    }

    fun setAddress(id: String, host: String, port: Int) = prefs.edit {
        putString("$id.host", host)
        putInt("$id.port", port)
    }

    fun setEnabled(id: String, enabled: Boolean) = prefs.edit { putBoolean("$id.enabled", enabled) }

    fun reset() = prefs.edit { clear() }
}
