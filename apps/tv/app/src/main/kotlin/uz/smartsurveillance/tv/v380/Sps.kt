package uz.smartsurveillance.tv.v380

/** Reads bits most significant first, with Exp-Golomb codes. */
class BitReader(private val data: ByteArray, start: Int = 0) {
    /** Position of the next bit from the first bit of the data. */
    var position = start * 8
        private set

    /** Bits left to read. */
    val remaining: Int get() = data.size * 8 - position

    /** Reads one bit. */
    fun bit(): Int {
        if (position >= data.size * 8) throw IllegalStateException("Read past the end")
        val value = (data[position ushr 3].toInt() ushr (7 - (position and 7))) and 1
        position += 1
        return value
    }

    /** Reads [count] bits, up to 32, as an unsigned value. */
    fun bits(count: Int): Long {
        var value = 0L
        repeat(count) { value = (value shl 1) or bit().toLong() }
        return value
    }

    /** Skips [count] bits. */
    fun skip(count: Int) {
        if (count > remaining) throw IllegalStateException("Read past the end")
        position += count
    }

    /** Reads an unsigned Exp-Golomb code. */
    fun ue(): Long {
        var zeros = 0
        while (bit() == 0) {
            zeros += 1
            if (zeros > 31) throw IllegalStateException("Exp-Golomb code too long")
        }
        return ((1L shl zeros) - 1) + bits(zeros)
    }

    /** Reads a signed Exp-Golomb code. */
    fun se(): Long {
        val code = ue()
        return if (code and 1L == 1L) (code + 1) / 2 else -(code / 2)
    }
}

/** Writes bits most significant first. */
class BitWriter {
    private val out = java.io.ByteArrayOutputStream()
    private var current = 0
    private var filled = 0

    /** Number of bits written. */
    var length = 0
        private set

    /** Writes one bit. */
    fun bit(value: Int) {
        current = (current shl 1) or (value and 1)
        filled += 1
        length += 1
        if (filled == 8) {
            out.write(current)
            current = 0
            filled = 0
        }
    }

    /** Writes the low [count] bits of [value]. */
    fun bits(value: Long, count: Int) {
        for (i in count - 1 downTo 0) bit(((value ushr i) and 1L).toInt())
    }

    /** Pads with zero bits to the next byte boundary and returns the bytes. */
    fun bytes(): ByteArray {
        while (filled != 0) bit(0)
        return out.toByteArray()
    }
}

/** Sequence parameter sets: emulation prevention, picture size and the low-latency reorder rewrite. */
object Sps {
    private const val NAL_HEADER_BITS = 16
    private const val PROFILE_GENERAL_BITS = 96
    private const val PROFILE_SUB_LAYER_BITS = 88
    private const val LEVEL_SUB_LAYER_BITS = 8

    /** Removes emulation prevention bytes: every 03 that follows two zero bytes. */
    fun removeEmulation(nal: ByteArray): ByteArray {
        val out = java.io.ByteArrayOutputStream(nal.size)
        var zeros = 0
        for (byte in nal) {
            val value = byte.toInt() and 0xFF
            if (zeros >= 2 && value == 3) {
                zeros = 0
                continue
            }
            out.write(value)
            zeros = if (value == 0) zeros + 1 else 0
        }
        return out.toByteArray()
    }

    /** Inserts emulation prevention bytes: 03 after two zero bytes that a byte of 0 to 3 would follow. */
    fun insertEmulation(rbsp: ByteArray): ByteArray {
        val out = java.io.ByteArrayOutputStream(rbsp.size + 8)
        var zeros = 0
        for (byte in rbsp) {
            val value = byte.toInt() and 0xFF
            if (zeros >= 2 && value <= 3) {
                out.write(3)
                zeros = 0
            }
            out.write(value)
            zeros = if (value == 0) zeros + 1 else 0
        }
        return out.toByteArray()
    }

    /**
     * The fields of an H.265 SPS this client reads.
     *
     * @property size Picture size after the conformance window.
     * @property reorder Bit position and length of each signalled sps_max_num_reorder_pics in the RBSP.
     * @property reorderValues The values of those fields.
     */
    class HevcFields(val size: VideoSize, val reorder: List<IntRange>, val reorderValues: List<Long>)

    /**
     * Parses an H.265 SPS NAL unit, without start code.
     *
     * @return The fields, or null when the SPS cannot be parsed.
     */
    fun hevc(nal: ByteArray): HevcFields? = runCatching { parseHevc(removeEmulation(nal)) }.getOrNull()

    /** The picture size of an H.265 SPS NAL unit, or null when it cannot be parsed. */
    fun hevcSize(nal: ByteArray): VideoSize? = hevc(nal)?.size

    /**
     * Rewrites every sps_max_num_reorder_pics of an H.265 SPS to 0, so a live decoder does not hold pictures back.
     *
     * Only valid for streams without B-frames, which holds for these cameras.
     *
     * @param nal The SPS NAL unit, without start code.
     * @return The rewritten NAL unit, or null when every field is already 0 or the SPS cannot be parsed.
     */
    fun hevcLowLatency(nal: ByteArray): ByteArray? {
        val rbsp = removeEmulation(nal)
        val fields = runCatching { parseHevc(rbsp) }.getOrNull() ?: return null
        if (fields.reorderValues.all { it == 0L }) return null
        val stop = stopBit(rbsp) ?: return null
        val reader = BitReader(rbsp)
        val writer = BitWriter()
        for (field in fields.reorder) {
            while (reader.position < field.first) writer.bit(reader.bit())
            reader.skip(field.last - field.first + 1)
            writer.bit(1)
        }
        while (reader.position < stop) writer.bit(reader.bit())
        writer.bit(1)
        return insertEmulation(writer.bytes())
    }

    private fun stopBit(rbsp: ByteArray): Int? {
        val last = rbsp.indexOfLast { it.toInt() != 0 }
        if (last < 0) return null
        val value = rbsp[last].toInt() and 0xFF
        return last * 8 + 7 - Integer.numberOfTrailingZeros(value)
    }

    private fun parseHevc(rbsp: ByteArray): HevcFields {
        val r = BitReader(rbsp)
        r.skip(NAL_HEADER_BITS)
        r.skip(4)
        val maxSubLayersMinus1 = r.bits(3).toInt()
        r.skip(1)
        profileTierLevel(r, maxSubLayersMinus1)
        r.ue()
        val chroma = r.ue().toInt()
        if (chroma == 3) r.skip(1)
        var width = r.ue()
        var height = r.ue()
        if (r.bit() == 1) {
            val subWidth = if (chroma == 1 || chroma == 2) 2 else 1
            val subHeight = if (chroma == 1) 2 else 1
            val left = r.ue()
            val right = r.ue()
            val top = r.ue()
            val bottom = r.ue()
            width -= subWidth * (left + right)
            height -= subHeight * (top + bottom)
        }
        r.ue()
        r.ue()
        r.ue()
        val orderingAll = r.bit() == 1
        val positions = ArrayList<IntRange>()
        val values = ArrayList<Long>()
        val first = if (orderingAll) 0 else maxSubLayersMinus1
        for (i in first..maxSubLayersMinus1) {
            r.ue()
            val begin = r.position
            values += r.ue()
            positions += begin until r.position
            r.ue()
        }
        if (width <= 0 || height <= 0) throw IllegalStateException("Empty picture")
        return HevcFields(VideoSize(width.toInt(), height.toInt()), positions, values)
    }

    private fun profileTierLevel(r: BitReader, maxSubLayersMinus1: Int) {
        r.skip(PROFILE_GENERAL_BITS)
        val profile = BooleanArray(maxSubLayersMinus1)
        val level = BooleanArray(maxSubLayersMinus1)
        for (i in 0 until maxSubLayersMinus1) {
            profile[i] = r.bit() == 1
            level[i] = r.bit() == 1
        }
        if (maxSubLayersMinus1 > 0) for (i in maxSubLayersMinus1 until 8) r.skip(2)
        for (i in 0 until maxSubLayersMinus1) {
            if (profile[i]) r.skip(PROFILE_SUB_LAYER_BITS)
            if (level[i]) r.skip(LEVEL_SUB_LAYER_BITS)
        }
    }

    /**
     * The picture size of an H.264 SPS NAL unit, without start code.
     *
     * @return The size after frame cropping, or null when the SPS cannot be parsed.
     */
    fun avcSize(nal: ByteArray): VideoSize? = runCatching { parseAvc(removeEmulation(nal)) }.getOrNull()

    private val HIGH_PROFILES = setOf(100, 110, 122, 244, 44, 83, 86, 118, 128, 138, 139, 134, 135)

    private fun parseAvc(rbsp: ByteArray): VideoSize {
        val r = BitReader(rbsp)
        r.skip(8)
        val profile = r.bits(8).toInt()
        r.skip(16)
        r.ue()
        var chroma = 1
        var separate = false
        if (profile in HIGH_PROFILES) {
            chroma = r.ue().toInt()
            if (chroma == 3) separate = r.bit() == 1
            r.ue()
            r.ue()
            r.skip(1)
            if (r.bit() == 1) {
                val lists = if (chroma != 3) 8 else 12
                for (i in 0 until lists) if (r.bit() == 1) scalingList(r, if (i < 6) 16 else 64)
            }
        }
        r.ue()
        when (r.ue().toInt()) {
            0 -> r.ue()
            1 -> {
                r.skip(1)
                r.se()
                r.se()
                val cycle = r.ue().toInt()
                repeat(cycle) { r.se() }
            }
        }
        r.ue()
        r.skip(1)
        val widthMbs = r.ue() + 1
        val heightUnits = r.ue() + 1
        val frameMbsOnly = r.bit()
        if (frameMbsOnly == 0) r.skip(1)
        r.skip(1)
        var width = widthMbs * 16
        var height = (2 - frameMbsOnly) * heightUnits * 16
        if (r.bit() == 1) {
            val arrayType = if (separate) 0 else chroma
            val cropX = if (arrayType == 1 || arrayType == 2) 2 else 1
            val cropY = (if (arrayType == 1) 2 else 1) * (2 - frameMbsOnly)
            val left = r.ue()
            val right = r.ue()
            val top = r.ue()
            val bottom = r.ue()
            width -= cropX * (left + right)
            height -= cropY * (top + bottom)
        }
        if (width <= 0 || height <= 0) throw IllegalStateException("Empty picture")
        return VideoSize(width.toInt(), height.toInt())
    }

    private fun scalingList(r: BitReader, size: Int) {
        var last = 8L
        var next = 8L
        for (j in 0 until size) {
            if (next != 0L) next = (last + r.se() + 256) % 256
            last = if (next == 0L) last else next
        }
    }
}
