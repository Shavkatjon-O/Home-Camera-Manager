package uz.smartsurveillance.tv.rtsp

data class Media(
    val type: String,
    val payload: Int,
    val codec: String,
    val clock: Int,
    val channels: Int,
    val control: String?,
    val fmtp: Map<String, String>,
)

data class Sdp(val control: String?, val media: List<Media>) {
    fun video(): Media? = media.firstOrNull { it.type == "video" && (it.codec == "H265" || it.codec == "H264") }

    fun audio(): Media? = media.firstOrNull { it.type == "audio" && it.codec == "MPEG4-GENERIC" }

    companion object {
        private class Builder(val type: String, val payload: Int) {
            var codec = ""
            var clock = 0
            var channels = 1
            var control: String? = null
            var fmtp: Map<String, String> = emptyMap()

            fun build() = Media(type, payload, codec, clock, channels, control, fmtp)
        }

        fun parse(text: String): Sdp {
            var sessionControl: String? = null
            val media = ArrayList<Media>()
            var current: Builder? = null
            for (raw in text.lines()) {
                val line = raw.trim()
                val section = current
                when {
                    line.startsWith("m=") -> {
                        section?.let { media += it.build() }
                        val parts = line.substring(2).split(' ')
                        current = Builder(parts[0], parts.getOrNull(3)?.toIntOrNull() ?: -1)
                    }
                    line.startsWith("a=control:") -> {
                        val value = line.substringAfter("a=control:").trim()
                        if (section == null) sessionControl = value else section.control = value
                    }
                    line.startsWith("a=rtpmap:") && section != null -> {
                        val spec = line.substringAfter(' ').split('/')
                        section.codec = spec[0].uppercase()
                        section.clock = spec.getOrNull(1)?.toIntOrNull() ?: 0
                        section.channels = spec.getOrNull(2)?.toIntOrNull() ?: 1
                    }
                    line.startsWith("a=fmtp:") && section != null -> {
                        section.fmtp = line.substringAfter(' ', "").split(';')
                            .map { it.trim() }
                            .filter { it.contains('=') }
                            .associate { it.substringBefore('=').trim().lowercase() to it.substringAfter('=').trim() }
                    }
                }
            }
            current?.let { media += it.build() }
            return Sdp(sessionControl, media)
        }

        fun resolve(base: String, control: String?): String {
            if (control.isNullOrEmpty() || control == "*") return base
            if (control.startsWith("rtsp://", ignoreCase = true)) return control
            return base.trimEnd('/') + "/" + control.trimStart('/')
        }
    }
}
