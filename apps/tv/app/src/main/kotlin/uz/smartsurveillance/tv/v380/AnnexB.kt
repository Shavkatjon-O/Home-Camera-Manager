package uz.smartsurveillance.tv.v380

/**
 * One NAL unit of an access unit.
 *
 * @property type NAL unit type, read the way the codec defines it.
 * @property bytes The NAL unit without its start code.
 */
class Nal(val type: Int, val bytes: ByteArray)

/** Annex-B byte streams: start code alignment, NAL unit splitting and codec identification. */
object AnnexB {
    /** H.265 video parameter set type. */
    const val HEVC_VPS = 32

    /** H.265 sequence parameter set type. */
    const val HEVC_SPS = 33

    /** H.265 picture parameter set type. */
    const val HEVC_PPS = 34

    /** H.264 sequence parameter set type. */
    const val AVC_SPS = 7

    /** H.264 picture parameter set type. */
    const val AVC_PPS = 8

    private const val ALIGN_WINDOW = 16
    private val FOUR_BYTE_START = byteArrayOf(0, 0, 0, 1)

    /**
     * Drops the bytes some firmware puts before the first start code.
     *
     * @param payload A decrypted video payload.
     * @return The payload from its first start code, or null when no start code begins in its first 16 bytes.
     */
    fun align(payload: ByteArray): ByteArray? {
        val found = payload.findStartCode(0, minOf(payload.size, ALIGN_WINDOW - 1 + 3))
        if (found < 0 || found > ALIGN_WINDOW - 1) return null
        val start = if (found > 0 && payload[found - 1].toInt() == 0) found - 1 else found
        return if (start == 0) payload else payload.copyOfRange(start, payload.size)
    }

    /** The H.265 NAL unit type of a NAL header byte. */
    fun hevcType(first: Byte): Int = (first.toInt() ushr 1) and 0x3F

    /** The H.264 NAL unit type of a NAL header byte. */
    fun avcType(first: Byte): Int = first.toInt() and 0x1F

    /**
     * Splits an access unit into its NAL units.
     *
     * @param data The access unit in Annex-B format.
     * @param codec How to read the NAL types.
     */
    fun nals(data: ByteArray, codec: Codec): List<Nal> {
        val out = ArrayList<Nal>()
        var start = data.findStartCode(0)
        while (start >= 0) {
            val begin = start + 3
            val following = data.findStartCode(begin)
            var end = if (following < 0) data.size else following
            if (following >= 0 && end > begin && data[end - 1].toInt() == 0) end -= 1
            if (end > begin) {
                val bytes = data.copyOfRange(begin, end)
                out += Nal(if (codec == Codec.Hevc) hevcType(bytes[0]) else avcType(bytes[0]), bytes)
            }
            start = following
        }
        return out
    }

    /**
     * Identifies the codec of a key access unit from its parameter set NAL headers.
     *
     * @param data A key access unit.
     * @return H.265 when it carries an H.265 VPS, SPS or PPS, otherwise H.264 when it carries an H.264 SPS or PPS,
     *     otherwise null.
     */
    fun codecOf(data: ByteArray): Codec? {
        val units = nals(data, Codec.Hevc)
        val hevc = units.any { nal ->
            nal.type in HEVC_VPS..HEVC_PPS && nal.bytes.size >= 2 && nal.bytes[1].toInt() == 1
        }
        if (hevc) return Codec.Hevc
        val avc = units.any { nal -> avcType(nal.bytes[0]) == AVC_SPS || avcType(nal.bytes[0]) == AVC_PPS }
        return if (avc) Codec.Avc else null
    }

    /**
     * Collects the parameter sets of a key access unit in decoder order.
     *
     * @param data The access unit.
     * @param codec Its codec.
     * @return VPS, SPS and PPS for H.265, or SPS and PPS for H.264; null when one is missing.
     */
    fun parameterSets(data: ByteArray, codec: Codec): List<Nal>? {
        val units = nals(data, codec)
        val wanted = if (codec == Codec.Hevc) listOf(HEVC_VPS, HEVC_SPS, HEVC_PPS) else listOf(AVC_SPS, AVC_PPS)
        return wanted.map { type -> units.firstOrNull { it.type == type } ?: return null }
    }

    /** Puts a four-byte start code in front of a NAL unit. */
    fun withStartCode(nal: ByteArray): ByteArray = FOUR_BYTE_START + nal
}
