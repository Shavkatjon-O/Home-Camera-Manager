package uz.smartsurveillance.tv.v380

const val HEADER_SIZE = 12
const val MAX_FRAGMENT = 20000

enum class FrameKind { Video, Audio, Other }

data class Fragment(val type: Int, val total: Int, val index: Int, val length: Int) {
    val kind: FrameKind
        get() = when (type) {
            0x00, 0x01, 0x28, 0x29 -> FrameKind.Video
            0x16, 0x18, 0x1A -> FrameKind.Audio
            else -> FrameKind.Other
        }

    val valid: Boolean get() = length in 1..MAX_FRAGMENT && total > 0 && index < total
}

class MediaFrame(
    val type: Int,
    val id: Long,
    val frameType: Int,
    val rate: Int,
    val timestamp: Long,
    val payload: ByteArray,
) {
    val key: Boolean get() = type == 0x00 || type == 0x28
}

fun parseFragment(header: ByteArray): Fragment? {
    if (header.size < HEADER_SIZE || header[0] != 0x7F.toByte()) return null
    return Fragment(
        type = header[1].toInt() and 0xFF,
        total = header.u16(3),
        index = header.u16(5),
        length = header.u16(7),
    )
}

class Assembler {
    private val parts = HashMap<FrameKind, Part>()

    var dropped = 0L
        private set

    private class Part {
        var total = 0
        var next = 0
        var size = 0
        var data = ByteArray(64 * 1024)

        fun reset(total: Int) {
            this.total = total
            next = 0
            size = 0
        }

        fun append(source: ByteArray, length: Int) {
            if (size + length > data.size) data = data.copyOf(maxOf(data.size * 2, size + length))
            source.copyInto(data, size, 0, length)
            size += length
            next += 1
        }
    }

    fun add(fragment: Fragment, payload: ByteArray): MediaFrame? {
        if (fragment.kind == FrameKind.Other) return null
        val part = parts.getOrPut(fragment.kind) { Part() }
        if (fragment.index == 0) {
            part.reset(fragment.total)
        } else if (fragment.total != part.total || fragment.index != part.next) {
            part.reset(0)
            dropped += 1
            return null
        }
        part.append(payload, fragment.length)
        if (fragment.index != fragment.total - 1) return null
        val size = part.size
        part.reset(0)
        if (size < 16) return null
        val data = part.data
        return MediaFrame(
            type = fragment.type,
            id = data.u32(0),
            frameType = data.u16(4),
            rate = data.u16(6),
            timestamp = data.u64(8),
            payload = data.copyOfRange(16, size),
        )
    }
}
