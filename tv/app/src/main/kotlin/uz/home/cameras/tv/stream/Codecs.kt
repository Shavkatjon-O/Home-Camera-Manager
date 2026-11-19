package uz.home.cameras.tv.stream

import android.media.MediaCodecInfo
import android.media.MediaCodecList
import android.os.Build

data class CodecInfo(
    val name: String,
    val mime: String,
    val hardware: Boolean,
    val maxInstances: Int,
    val maxWidth: Int,
    val maxHeight: Int,
    val info: MediaCodecInfo,
) {
    fun supports(width: Int, height: Int): Boolean = runCatching {
        info.getCapabilitiesForType(mime).videoCapabilities?.isSizeSupported(width, height) ?: false
    }.getOrDefault(false)
}

object Codecs {
    val all: List<CodecInfo> by lazy { load() }

    fun decoders(mime: String): List<CodecInfo> = all.filter { it.mime == mime }

    fun candidates(mime: String, width: Int, height: Int): List<CodecInfo> =
        decoders(mime).filter { it.supports(width, height) }.sortedBy { if (it.hardware) 0 else 1 }

    fun hardwareFits(mime: String, width: Int, height: Int): Boolean {
        val list = decoders(mime)
        if (list.none { it.hardware }) return list.any { it.supports(width, height) }
        return list.any { it.hardware && it.supports(width, height) }
    }

    private fun load(): List<CodecInfo> {
        val result = ArrayList<CodecInfo>()
        val infos = runCatching { MediaCodecList(MediaCodecList.REGULAR_CODECS).codecInfos }.getOrDefault(emptyArray())
        for (info in infos) {
            if (info.isEncoder) continue
            for (mime in info.supportedTypes) {
                val lower = mime.lowercase()
                if (lower != "video/hevc" && lower != "video/avc") continue
                if (info.name.endsWith(".secure")) continue
                val caps = runCatching { info.getCapabilitiesForType(mime) }.getOrNull() ?: continue
                val video = caps.videoCapabilities
                result += CodecInfo(
                    name = info.name,
                    mime = lower,
                    hardware = hardware(info),
                    maxInstances = runCatching { caps.maxSupportedInstances }.getOrDefault(0),
                    maxWidth = video?.supportedWidths?.upper ?: 0,
                    maxHeight = video?.supportedHeights?.upper ?: 0,
                    info = info,
                )
            }
        }
        return result
    }

    private fun hardware(info: MediaCodecInfo): Boolean {
        if (Build.VERSION.SDK_INT >= 29) return info.isHardwareAccelerated && !info.isSoftwareOnly
        val name = info.name.lowercase()
        return !(name.startsWith("omx.google.") || name.startsWith("c2.android.") || name.startsWith("c2.google.") || name.contains("ffmpeg"))
    }
}
