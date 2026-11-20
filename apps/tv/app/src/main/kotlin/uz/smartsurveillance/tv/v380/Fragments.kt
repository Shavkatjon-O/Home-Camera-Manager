package uz.smartsurveillance.tv.v380

/** Media frame types and how they are grouped. */
object FrameType {
    /** H.264 key frame. */
    const val AVC_KEY = 0x00

    /** H.264 non-key frame. */
    const val AVC = 0x01

    /** H.265 key frame. */
    const val HEVC_KEY = 0x28

    /** H.265 non-key frame. */
    const val HEVC = 0x29

    /** IMA ADPCM audio, 8 kHz mono. */
    const val ADPCM = 0x16

    /** AAC audio in ADTS frames. */
    const val AAC = 0x18

    /** G.711 A-law audio, 8 kHz mono. */
    const val ALAW = 0x1A

    /** A type of unknown meaning that cameras send and clients skip. */
    const val SKIPPED = 0x5B

    /**
     * Whether the type is one the cameras are known to send.
     *
     * While the client scans for a header after losing its place, it accepts only these types, which makes a
     * header found inside a payload by chance much less likely.
     */
    fun isKnown(type: Int): Boolean = isVideo(type) || isAudio(type) || type == SKIPPED

    /** Whether the type carries video. */
    fun isVideo(type: Int): Boolean = type == AVC_KEY || type == AVC || type == HEVC_KEY || type == HEVC

    /** Whether the type carries audio. */
    fun isAudio(type: Int): Boolean = type == ADPCM || type == AAC || type == ALAW

    /** Whether the type is a video key frame. */
    fun isKey(type: Int): Boolean = type == AVC_KEY || type == HEVC_KEY

    /** The codec family a video type belongs to. */
    fun codec(type: Int): Codec? = when (type) {
        AVC_KEY, AVC -> Codec.Avc
        HEVC_KEY, HEVC -> Codec.Hevc
        else -> null
    }
}

/**
 * The 12-byte header in front of every media fragment.
 *
 * @property type Frame type.
 * @property count Number of fragments in the frame.
 * @property index Index of this fragment in its frame.
 * @property length Payload length of this fragment.
 */
data class FragmentHeader(val type: Int, val count: Int, val index: Int, val length: Int) {
    /** Header layout and limits. */
    companion object {
        /** Size of a fragment header. */
        const val SIZE = 12

        /** Marker byte that starts every header. */
        const val MARKER = 0x7F

        /** Largest payload a valid header may announce. */
        const val MAX_LENGTH = 20000

        /**
         * Reads a header, or returns null when it is not valid.
         *
         * @param data Bytes holding the header.
         * @param offset Where the header starts.
         */
        fun parse(data: ByteArray, offset: Int = 0): FragmentHeader? {
            if (data.size - offset < SIZE || data.u8(offset) != MARKER) return null
            val count = data.u16(offset + 3)
            val index = data.u16(offset + 5)
            val length = data.u16(offset + 7)
            if (count < 1 || index >= count || length < 1 || length > MAX_LENGTH) return null
            return FragmentHeader(data.u8(offset + 1), count, index, length)
        }

        /** Builds a header with the unnamed bytes zero. */
        fun build(type: Int, count: Int, index: Int, length: Int): ByteArray {
            val out = ByteArray(SIZE)
            out.put8(0, MARKER)
            out.put8(1, type)
            out.put16(3, count)
            out.put16(5, index)
            out.put16(7, length)
            return out
        }
    }
}

/**
 * The 16 clear bytes at the start of every complete frame.
 *
 * @property number Frame number.
 * @property innerType Inner frame type.
 * @property rate Frame rate in frames per second, as the camera reports it.
 * @property timestamp Camera timestamp, assumed milliseconds; never used as a presentation time.
 */
data class FrameHeader(val number: Long, val innerType: Int, val rate: Int, val timestamp: Long) {
    /** Header layout. */
    companion object {
        /** Size of a frame header. */
        const val SIZE = 16

        /** Reads the header at the start of a frame. */
        fun parse(frame: ByteArray): FrameHeader =
            FrameHeader(frame.u32(0), frame.u16(4), frame.u16(6), frame.u64(8))

        /** Builds a header. */
        fun build(number: Long, innerType: Int, rate: Int, timestamp: Long): ByteArray {
            val out = ByteArray(SIZE)
            out.put32(0, number)
            out.put16(4, innerType)
            out.put16(6, rate)
            out.put64(8, timestamp)
            return out
        }
    }
}

/**
 * A reassembled frame.
 *
 * @property type Frame type of its fragments.
 * @property data Frame header followed by the still encrypted media payload.
 */
class Frame(val type: Int, val data: ByteArray) {
    /** The clear frame header. */
    val header: FrameHeader get() = FrameHeader.parse(data)
}

/**
 * Joins fragments into frames, with one buffer for video and one for audio, and never delivers a frame with a
 * missing, repeated or reordered fragment.
 */
class Reassembler {
    private val video = Partial()
    private val audio = Partial()

    /** Frames discarded because a fragment was missing, repeated or out of order. */
    var dropped = 0
        private set

    /**
     * Adds one fragment.
     *
     * @param header The fragment's valid header.
     * @param payload Its payload.
     * @return The completed frame, or null while the frame is incomplete, was discarded or is of an ignored type.
     */
    fun push(header: FragmentHeader, payload: ByteArray): Frame? {
        val partial = when {
            FrameType.isVideo(header.type) -> video
            FrameType.isAudio(header.type) -> audio
            else -> return null
        }
        if (header.index == 0) {
            if (partial.active) dropped += 1
            partial.begin(header)
        } else if (partial.active && header.count == partial.count && header.index == partial.next) {
            partial.append(payload)
        } else {
            if (partial.active || !partial.broken) dropped += 1
            partial.reset(broken = true)
            return null
        }
        if (header.index == 0) partial.append(payload)
        if (partial.next < partial.count) return null
        val data = partial.take()
        if (data.size < FrameHeader.SIZE) return null
        return Frame(partial.type, data)
    }

    private class Partial {
        var active = false
        var broken = false
        var type = 0
        var count = 0
        var next = 0
        private var buffer = java.io.ByteArrayOutputStream()

        fun begin(header: FragmentHeader) {
            active = true
            broken = false
            type = header.type
            count = header.count
            next = 0
            buffer = java.io.ByteArrayOutputStream(header.length * header.count)
        }

        fun append(payload: ByteArray) {
            buffer.write(payload)
            next += 1
        }

        fun take(): ByteArray {
            val out = buffer.toByteArray()
            reset(broken = false)
            return out
        }

        fun reset(broken: Boolean) {
            active = false
            this.broken = broken
            count = 0
            next = 0
            buffer = java.io.ByteArrayOutputStream()
        }
    }
}
