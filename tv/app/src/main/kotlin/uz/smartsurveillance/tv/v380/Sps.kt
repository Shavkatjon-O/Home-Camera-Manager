package uz.smartsurveillance.tv.v380

data class VideoSize(val width: Int, val height: Int)

private class Bits(private val data: ByteArray) {
    var position = 0
        private set

    fun bit(): Int {
        val index = position shr 3
        if (index >= data.size) throw IllegalStateException("end of data")
        val value = (data[index].toInt() shr (7 - (position and 7))) and 1
        position += 1
        return value
    }

    fun bits(count: Int): Int {
        var value = 0
        repeat(count) { value = (value shl 1) or bit() }
        return value
    }

    fun skip(count: Int) {
        position += count
    }

    fun ue(): Int {
        var zeros = 0
        while (bit() == 0) {
            zeros += 1
            if (zeros > 31) throw IllegalStateException("bad exp-golomb")
        }
        return ((1 shl zeros) - 1) + bits(zeros)
    }
}

private fun writeUe(out: MutableList<Int>, value: Int) {
    val code = value + 1
    val length = 32 - Integer.numberOfLeadingZeros(code)
    repeat(length - 1) { out += 0 }
    for (i in length - 1 downTo 0) out += (code shr i) and 1
}

object Sps {
    fun escape(rbsp: ByteArray): ByteArray {
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

    fun hevcReorder(nal: ByteArray): List<Int>? = runCatching { orderingFields(unescape(nal)).map { it.third } }.getOrNull()

    fun hevcLowLatency(nal: ByteArray): ByteArray? = runCatching {
        val rbsp = unescape(nal)
        val fields = orderingFields(rbsp)
        if (fields.all { it.third == 0 }) return null
        val total = rbsp.size * 8
        val bit = { index: Int -> (rbsp[index shr 3].toInt() shr (7 - (index and 7))) and 1 }
        var stop = total - 1
        while (stop >= 0 && bit(stop) == 0) stop -= 1
        if (stop < 0) return null
        val out = ArrayList<Int>(total)
        var at = 0
        for ((start, end, _) in fields) {
            while (at < start) out += bit(at++)
            writeUe(out, 0)
            at = end
        }
        while (at < stop) out += bit(at++)
        out += 1
        while (out.size % 8 != 0) out += 0
        val bytes = ByteArray(out.size / 8) { index ->
            var value = 0
            for (i in 0 until 8) value = (value shl 1) or out[index * 8 + i]
            value.toByte()
        }
        escape(bytes)
    }.getOrNull()

    private fun orderingFields(rbsp: ByteArray): List<Triple<Int, Int, Int>> {
        val bits = Bits(rbsp)
        bits.skip(16)
        bits.skip(4)
        val maxSubLayersMinus1 = bits.bits(3)
        bits.skip(1)
        bits.skip(96)
        val profilePresent = IntArray(maxSubLayersMinus1)
        val levelPresent = IntArray(maxSubLayersMinus1)
        for (i in 0 until maxSubLayersMinus1) {
            profilePresent[i] = bits.bit()
            levelPresent[i] = bits.bit()
        }
        if (maxSubLayersMinus1 > 0) for (i in maxSubLayersMinus1 until 8) bits.skip(2)
        for (i in 0 until maxSubLayersMinus1) {
            if (profilePresent[i] == 1) bits.skip(88)
            if (levelPresent[i] == 1) bits.skip(8)
        }
        bits.ue()
        val chroma = bits.ue()
        if (chroma == 3) bits.skip(1)
        bits.ue()
        bits.ue()
        if (bits.bit() == 1) repeat(4) { bits.ue() }
        bits.ue()
        bits.ue()
        bits.ue()
        val present = bits.bit()
        val fields = ArrayList<Triple<Int, Int, Int>>()
        for (i in (if (present == 1) 0 else maxSubLayersMinus1)..maxSubLayersMinus1) {
            bits.ue()
            val start = bits.position
            val reorder = bits.ue()
            fields += Triple(start, bits.position, reorder)
            bits.ue()
        }
        return fields
    }

    fun unescape(nal: ByteArray): ByteArray {
        val out = ByteArray(nal.size)
        var size = 0
        var zeros = 0
        for (byte in nal) {
            val value = byte.toInt() and 0xFF
            if (zeros >= 2 && value == 3) {
                zeros = 0
                continue
            }
            out[size++] = byte
            zeros = if (value == 0) zeros + 1 else 0
        }
        return out.copyOf(size)
    }

    fun hevcSize(nal: ByteArray): VideoSize? = runCatching {
        val bits = Bits(unescape(nal))
        bits.skip(16)
        bits.skip(4)
        val maxSubLayersMinus1 = bits.bits(3)
        bits.skip(1)
        bits.skip(96)
        val profilePresent = IntArray(maxSubLayersMinus1)
        val levelPresent = IntArray(maxSubLayersMinus1)
        for (i in 0 until maxSubLayersMinus1) {
            profilePresent[i] = bits.bit()
            levelPresent[i] = bits.bit()
        }
        if (maxSubLayersMinus1 > 0) for (i in maxSubLayersMinus1 until 8) bits.skip(2)
        for (i in 0 until maxSubLayersMinus1) {
            if (profilePresent[i] == 1) bits.skip(88)
            if (levelPresent[i] == 1) bits.skip(8)
        }
        bits.ue()
        val chroma = bits.ue()
        if (chroma == 3) bits.skip(1)
        var width = bits.ue()
        var height = bits.ue()
        if (bits.bit() == 1) {
            val subWidth = if (chroma == 1 || chroma == 2) 2 else 1
            val subHeight = if (chroma == 1) 2 else 1
            val left = bits.ue()
            val right = bits.ue()
            val top = bits.ue()
            val bottom = bits.ue()
            width -= subWidth * (left + right)
            height -= subHeight * (top + bottom)
        }
        if (width <= 0 || height <= 0) null else VideoSize(width, height)
    }.getOrNull()
}
