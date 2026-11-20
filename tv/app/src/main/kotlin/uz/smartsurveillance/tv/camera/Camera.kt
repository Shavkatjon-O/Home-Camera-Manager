package uz.smartsurveillance.tv.camera

import java.io.StringReader
import java.util.Properties

enum class Kind { Rtsp, V380 }

data class Camera(
    val id: String,
    val name: String,
    val kind: Kind,
    val host: String,
    val port: Int,
    val user: String,
    val password: String,
    val deviceId: Long = 0,
    val mainPath: String = "",
    val subPath: String = "",
    val lenses: Int = 1,
    val enabled: Boolean = true,
) {
    val ptz: Boolean get() = kind == Kind.V380

    val defaultPort: Int get() = if (kind == Kind.V380) 8800 else 554

    val address: String get() = if (port == defaultPort) host else "$host:$port"

    fun url(main: Boolean): String {
        val path = if (main || subPath.isBlank()) mainPath else subPath
        val credentials = if (user.isEmpty()) "" else "${encode(user)}:${encode(password)}@"
        return "rtsp://$credentials$host:$port$path"
    }

    fun withAddress(address: String): Camera? {
        val parsed = parseAddress(address, defaultPort) ?: return null
        return copy(host = parsed.first, port = parsed.second)
    }

    companion object {
        fun encode(text: String): String = buildString {
            for (byte in text.toByteArray(Charsets.UTF_8)) {
                val c = byte.toInt() and 0xFF
                val ch = c.toChar()
                if (ch.isLetterOrDigit() && c < 128 || ch in "-._~") append(ch) else append("%%%02X".format(c))
            }
        }

        fun parseAddress(text: String, defaultPort: Int): Pair<String, Int>? {
            val trimmed = text.trim()
            if (trimmed.isEmpty() || trimmed.any { it.isWhitespace() || it == '/' || it == '@' }) return null
            val host = trimmed.substringBefore(':')
            val portText = trimmed.substringAfter(':', "")
            if (host.isEmpty()) return null
            if (portText.isEmpty()) return host to defaultPort
            val port = portText.toIntOrNull() ?: return null
            if (port !in 1..65535) return null
            return host to port
        }

        fun parse(text: String): List<Camera> {
            val props = Properties().apply { load(StringReader(text)) }
            val ids = props.getProperty("cameras", "").split(',').map { it.trim() }.filter { it.isNotEmpty() }
            return ids.mapNotNull { id ->
                fun value(key: String): String? = props.getProperty("$id.$key")?.trim()
                val kind = when (value("kind")?.lowercase()) {
                    "v380" -> Kind.V380
                    "rtsp" -> Kind.Rtsp
                    else -> return@mapNotNull null
                }
                val host = value("host") ?: return@mapNotNull null
                val defaultPort = if (kind == Kind.V380) 8800 else 554
                Camera(
                    id = id,
                    name = value("name") ?: id,
                    kind = kind,
                    host = host,
                    port = value("port")?.toIntOrNull() ?: defaultPort,
                    user = value("user") ?: "admin",
                    password = props.getProperty("$id.password") ?: "",
                    deviceId = value("device")?.toLongOrNull() ?: 0,
                    mainPath = value("main") ?: "",
                    subPath = value("sub") ?: "",
                    lenses = value("lenses")?.toIntOrNull()?.coerceIn(1, 4) ?: 1,
                    enabled = value("enabled")?.toBooleanStrictOrNull() ?: true,
                )
            }
        }
    }
}
