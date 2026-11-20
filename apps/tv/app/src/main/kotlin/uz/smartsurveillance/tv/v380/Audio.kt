package uz.smartsurveillance.tv.v380

/** IMA ADPCM blocks with a 4-byte header and 4-bit codes, low nibble first. */
object ImaAdpcm {
    private const val HEADER = 4

    private val STEPS = intArrayOf(
        7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97,
        107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
        876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428,
        4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385,
        24623, 27086, 29794, 32767,
    )

    private val INDEX_CHANGE = intArrayOf(-1, -1, -1, -1, 2, 4, 6, 8)

    /**
     * Decodes one block to 16-bit samples.
     *
     * @param data Bytes holding the block.
     * @param offset Where it starts.
     * @param length Its length; a 256-byte block gives 505 samples.
     * @return The header sample followed by two samples per code byte.
     */
    fun decodeBlock(data: ByteArray, offset: Int, length: Int): ShortArray {
        if (length < HEADER) return ShortArray(0)
        var sample = ((data[offset].toInt() and 0xFF) or (data[offset + 1].toInt() shl 8)).toShort().toInt()
        var index = (data[offset + 2].toInt() and 0xFF).coerceIn(0, STEPS.size - 1)
        val out = ShortArray(1 + (length - HEADER) * 2)
        out[0] = sample.toShort()
        var at = 1
        for (i in offset + HEADER until offset + length) {
            val byte = data[i].toInt() and 0xFF
            for (code in intArrayOf(byte and 0x0F, byte ushr 4)) {
                val step = STEPS[index]
                var diff = step ushr 3
                if (code and 4 != 0) diff += step
                if (code and 2 != 0) diff += step ushr 1
                if (code and 1 != 0) diff += step ushr 2
                sample = if (code and 8 != 0) sample - diff else sample + diff
                sample = sample.coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt())
                index = (index + INDEX_CHANGE[code and 7]).coerceIn(0, STEPS.size - 1)
                out[at++] = sample.toShort()
            }
        }
        return out
    }
}

/** G.711 A-law samples, one byte each. */
object Alaw {
    /** Decodes one A-law byte to a 16-bit sample. */
    fun sample(code: Int): Int {
        val a = (code and 0xFF) xor 0x55
        val exponent = (a ushr 4) and 7
        val mantissa = a and 0x0F
        val magnitude = if (exponent == 0) (mantissa shl 4) + 8 else ((mantissa shl 4) + 0x108) shl (exponent - 1)
        return if (a and 0x80 != 0) magnitude else -magnitude
    }

    /** Decodes [length] A-law bytes from [offset]. */
    fun decode(data: ByteArray, offset: Int, length: Int): ShortArray =
        ShortArray(length) { sample(data[offset + it].toInt()).toShort() }
}

/** ADTS headers of AAC frames. */
object Adts {
    private val RATES = intArrayOf(96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 7350)

    /**
     * One ADTS header.
     *
     * @property objectType MPEG-4 audio object type, 2 for AAC LC.
     * @property rateIndex Sampling frequency index.
     * @property sampleRate Sampling rate in Hz.
     * @property channels Channel configuration.
     * @property headerSize 7 without CRC, 9 with it.
     * @property frameSize Frame length including the header.
     */
    data class Header(
        val objectType: Int,
        val rateIndex: Int,
        val sampleRate: Int,
        val channels: Int,
        val headerSize: Int,
        val frameSize: Int,
    ) {
        /** The two-byte AudioSpecificConfig a decoder is configured with. */
        fun config(): ByteArray {
            val value = (objectType shl 11) or (rateIndex shl 7) or (channels shl 3)
            return byteArrayOf((value ushr 8).toByte(), value.toByte())
        }
    }

    /**
     * Reads the ADTS header at the start of a frame.
     *
     * @return The header, or null when the frame does not start with a valid one.
     */
    fun parse(data: ByteArray, offset: Int = 0): Header? {
        if (data.size - offset < 7) return null
        val b = IntArray(7) { data[offset + it].toInt() and 0xFF }
        if (b[0] != 0xFF || b[1] and 0xF0 != 0xF0) return null
        val protectionAbsent = b[1] and 1
        val profile = b[2] ushr 6
        val rateIndex = (b[2] ushr 2) and 0x0F
        if (rateIndex >= RATES.size) return null
        val channels = ((b[2] and 1) shl 2) or (b[3] ushr 6)
        val frameSize = ((b[3] and 3) shl 11) or (b[4] shl 3) or (b[5] ushr 5)
        val headerSize = if (protectionAbsent == 1) 7 else 9
        if (frameSize < headerSize) return null
        return Header(profile + 1, rateIndex, RATES[rateIndex], channels, headerSize, frameSize)
    }
}
