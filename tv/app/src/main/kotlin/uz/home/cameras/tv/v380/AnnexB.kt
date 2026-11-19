package uz.home.cameras.tv.v380

enum class Codec(val mime: String) { Hevc("video/hevc"), Avc("video/avc") }

class Nal(val type: Int, val bytes: ByteArray)

object AnnexB {
    fun startCodeAt(data: ByteArray, limit: Int = 16): Int {
        val end = minOf(limit, data.size - 3)
        for (i in 0 until end) {
            if (data[i].toInt() == 0 && data[i + 1].toInt() == 0 && data[i + 2].toInt() == 1) {
                return if (i > 0 && data[i - 1].toInt() == 0) i - 1 else i
            }
        }
        return -1
    }

    fun trim(data: ByteArray): ByteArray? {
        val at = startCodeAt(data)
        if (at < 0) return null
        return if (at == 0) data else data.copyOfRange(at, data.size)
    }

    fun units(data: ByteArray): List<IntRange> {
        val starts = ArrayList<Pair<Int, Int>>()
        var i = 0
        while (i + 2 < data.size) {
            if (data[i].toInt() == 0 && data[i + 1].toInt() == 0 && data[i + 2].toInt() == 1) {
                val prefix = if (i > 0 && data[i - 1].toInt() == 0) i - 1 else i
                starts += prefix to i + 3
                i += 3
            } else {
                i += 1
            }
        }
        return starts.mapIndexed { index, (_, body) ->
            val end = if (index + 1 < starts.size) starts[index + 1].first else data.size
            body until end
        }.filter { !it.isEmpty() }
    }

    fun codecOf(data: ByteArray): Codec? {
        for (range in units(data)) {
            val first = data[range.first].toInt() and 0xFF
            val hevcType = (first shr 1) and 0x3F
            if (hevcType in 32..34 && range.last > range.first && data[range.first + 1].toInt() == 1) return Codec.Hevc
            val avcType = first and 0x1F
            if (avcType == 7 || avcType == 8) return Codec.Avc
        }
        return null
    }

    fun nals(data: ByteArray, codec: Codec): List<Nal> = units(data).map { range ->
        val first = data[range.first].toInt() and 0xFF
        val type = if (codec == Codec.Hevc) (first shr 1) and 0x3F else first and 0x1F
        Nal(type, data.copyOfRange(range.first, range.last + 1))
    }

    fun parameterSets(data: ByteArray, codec: Codec): List<Nal>? {
        val wanted = if (codec == Codec.Hevc) listOf(32, 33, 34) else listOf(7, 8)
        val found = nals(data, codec).filter { it.type in wanted }.distinctBy { it.type }
        if (found.size != wanted.size) return null
        return wanted.map { type -> found.first { it.type == type } }
    }

    fun withStartCode(nal: ByteArray): ByteArray = byteArrayOf(0, 0, 0, 1) + nal
}
