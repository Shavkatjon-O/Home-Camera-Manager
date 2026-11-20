package uz.smartsurveillance.tv.v380

object Alaw {
    private val table = ShortArray(256) { decodeOne(it).toShort() }

    private fun decodeOne(code: Int): Int {
        val value = code xor 0x55
        var t = (value and 0x0F) shl 4
        val segment = (value and 0x70) shr 4
        t = when (segment) {
            0 -> t + 8
            1 -> t + 0x108
            else -> (t + 0x108) shl (segment - 1)
        }
        return if (value and 0x80 != 0) t else -t
    }

    fun sample(code: Byte): Short = table[code.toInt() and 0xFF]

    fun decode(data: ByteArray, offset: Int, length: Int, out: ShortArray = ShortArray(length)): ShortArray {
        for (i in 0 until length) out[i] = table[data[offset + i].toInt() and 0xFF]
        return out
    }
}

object ImaAdpcm {
    private val steps = intArrayOf(
        7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
        50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
        337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
        2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
        15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767,
    )
    private val indexes = intArrayOf(-1, -1, -1, -1, 2, 4, 6, 8, -1, -1, -1, -1, 2, 4, 6, 8)

    fun decodeBlock(data: ByteArray, offset: Int, length: Int): ShortArray {
        if (length < 4) return ShortArray(0)
        var predictor = (data[offset].toInt() and 0xFF) or (data[offset + 1].toInt() shl 8)
        var index = (data[offset + 2].toInt() and 0xFF).coerceIn(0, 88)
        val out = ShortArray(1 + (length - 4) * 2)
        out[0] = predictor.toShort()
        var n = 1
        for (i in offset + 4 until offset + length) {
            val byte = data[i].toInt() and 0xFF
            for (nibble in intArrayOf(byte and 0x0F, byte shr 4)) {
                val step = steps[index]
                var diff = step shr 3
                if (nibble and 4 != 0) diff += step
                if (nibble and 2 != 0) diff += step shr 1
                if (nibble and 1 != 0) diff += step shr 2
                predictor = if (nibble and 8 != 0) predictor - diff else predictor + diff
                predictor = predictor.coerceIn(-32768, 32767)
                index = (index + indexes[nibble]).coerceIn(0, 88)
                out[n++] = predictor.toShort()
            }
        }
        return out
    }
}

data class Adts(val objectType: Int, val rateIndex: Int, val channels: Int, val headerSize: Int, val frameSize: Int) {
    val sampleRate: Int get() = RATES.getOrElse(rateIndex) { 8000 }

    fun config(): ByteArray = byteArrayOf(
        ((objectType shl 3) or (rateIndex shr 1)).toByte(),
        (((rateIndex and 1) shl 7) or (channels shl 3)).toByte(),
    )

    companion object {
        val RATES = intArrayOf(96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 7350)

        fun parse(data: ByteArray): Adts? {
            if (data.size < 7) return null
            val b0 = data[0].toInt() and 0xFF
            val b1 = data[1].toInt() and 0xFF
            if (b0 != 0xFF || b1 and 0xF6 != 0xF0) return null
            val b2 = data[2].toInt() and 0xFF
            val b3 = data[3].toInt() and 0xFF
            val b4 = data[4].toInt() and 0xFF
            val b5 = data[5].toInt() and 0xFF
            val rateIndex = (b2 shr 2) and 0x0F
            if (rateIndex >= RATES.size) return null
            return Adts(
                objectType = ((b2 shr 6) and 3) + 1,
                rateIndex = rateIndex,
                channels = ((b2 and 1) shl 2) or (b3 shr 6),
                headerSize = if (b1 and 1 == 1) 7 else 9,
                frameSize = ((b3 and 3) shl 11) or (b4 shl 3) or (b5 shr 5),
            )
        }
    }
}
