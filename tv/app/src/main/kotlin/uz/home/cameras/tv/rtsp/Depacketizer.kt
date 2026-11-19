package uz.home.cameras.tv.rtsp

import java.io.ByteArrayOutputStream
import uz.home.cameras.tv.v380.Codec

data class Rtp(val marker: Boolean, val payloadType: Int, val sequence: Int, val timestamp: Long, val offset: Int, val length: Int)

fun parseRtp(packet: ByteArray, size: Int): Rtp? {
    if (size < 12) return null
    val b0 = packet[0].toInt() and 0xFF
    if (b0 shr 6 != 2) return null
    val csrc = b0 and 0x0F
    var offset = 12 + csrc * 4
    if (b0 and 0x10 != 0) {
        if (size < offset + 4) return null
        val words = ((packet[offset + 2].toInt() and 0xFF) shl 8) or (packet[offset + 3].toInt() and 0xFF)
        offset += 4 + words * 4
    }
    var end = size
    if (b0 and 0x20 != 0) end -= packet[size - 1].toInt() and 0xFF
    if (end <= offset) return null
    val b1 = packet[1].toInt() and 0xFF
    val sequence = ((packet[2].toInt() and 0xFF) shl 8) or (packet[3].toInt() and 0xFF)
    var timestamp = 0L
    for (i in 4 until 8) timestamp = (timestamp shl 8) or (packet[i].toLong() and 0xFF)
    return Rtp(b1 and 0x80 != 0, b1 and 0x7F, sequence, timestamp, offset, end - offset)
}

class VideoDepacketizer(private val codec: Codec, private val onUnit: (ByteArray, Boolean) -> Unit) {
    private val unit = ByteArrayOutputStream(256 * 1024)
    private var fragment: ByteArrayOutputStream? = null
    private var fragmentType = 0
    private var timestamp = -1L
    private var lastSequence = -1
    private var broken = false
    private var key = false

    var dropped = 0L
        private set

    fun push(packet: ByteArray, rtp: Rtp) {
        if (lastSequence >= 0 && rtp.sequence != (lastSequence + 1) and 0xFFFF) {
            broken = true
            fragment = null
        }
        lastSequence = rtp.sequence
        if (timestamp >= 0 && rtp.timestamp != timestamp && unit.size() > 0) flush()
        timestamp = rtp.timestamp
        if (codec == Codec.Hevc) hevc(packet, rtp.offset, rtp.length) else avc(packet, rtp.offset, rtp.length)
        if (rtp.marker) flush()
    }

    private fun hevc(data: ByteArray, offset: Int, length: Int) {
        if (length < 3) return
        val type = (data[offset].toInt() shr 1) and 0x3F
        when (type) {
            48 -> {
                var at = offset + 2
                val end = offset + length
                while (at + 2 <= end) {
                    val size = ((data[at].toInt() and 0xFF) shl 8) or (data[at + 1].toInt() and 0xFF)
                    at += 2
                    if (size <= 0 || at + size > end) break
                    nal(data, at, size, (data[at].toInt() shr 1) and 0x3F)
                    at += size
                }
            }
            49 -> {
                val header = data[offset + 2].toInt() and 0xFF
                val start = header and 0x80 != 0
                val stop = header and 0x40 != 0
                val nalType = header and 0x3F
                if (start) {
                    fragmentType = nalType
                    fragment = ByteArrayOutputStream().apply {
                        write((data[offset].toInt() and 0x81) or (nalType shl 1))
                        write(data[offset + 1].toInt())
                    }
                }
                val current = fragment ?: return
                current.write(data, offset + 3, length - 3)
                if (stop) {
                    val bytes = current.toByteArray()
                    fragment = null
                    nal(bytes, 0, bytes.size, fragmentType)
                }
            }
            else -> nal(data, offset, length, type)
        }
    }

    private fun avc(data: ByteArray, offset: Int, length: Int) {
        if (length < 2) return
        val type = data[offset].toInt() and 0x1F
        when (type) {
            24 -> {
                var at = offset + 1
                val end = offset + length
                while (at + 2 <= end) {
                    val size = ((data[at].toInt() and 0xFF) shl 8) or (data[at + 1].toInt() and 0xFF)
                    at += 2
                    if (size <= 0 || at + size > end) break
                    nal(data, at, size, data[at].toInt() and 0x1F)
                    at += size
                }
            }
            28 -> {
                val header = data[offset + 1].toInt() and 0xFF
                val nalType = header and 0x1F
                if (header and 0x80 != 0) {
                    fragmentType = nalType
                    fragment = ByteArrayOutputStream().apply { write((data[offset].toInt() and 0xE0) or nalType) }
                }
                val current = fragment ?: return
                current.write(data, offset + 2, length - 2)
                if (header and 0x40 != 0) {
                    val bytes = current.toByteArray()
                    fragment = null
                    nal(bytes, 0, bytes.size, fragmentType)
                }
            }
            else -> nal(data, offset, length, type)
        }
    }

    private fun nal(data: ByteArray, offset: Int, length: Int, type: Int) {
        unit.write(START, 0, START.size)
        unit.write(data, offset, length)
        if (codec == Codec.Hevc && type in 16..21) key = true
        if (codec == Codec.Avc && type == 5) key = true
    }

    private fun flush() {
        if (unit.size() > 0) {
            if (broken) dropped += 1 else onUnit(unit.toByteArray(), key)
        }
        unit.reset()
        key = false
        broken = false
    }

    private companion object {
        val START = byteArrayOf(0, 0, 0, 1)
    }
}

object AacUnits {
    fun split(data: ByteArray, offset: Int, length: Int, sizeLength: Int = 13, indexLength: Int = 3): List<Pair<Int, Int>> {
        if (length < 2) return emptyList()
        val headerBits = ((data[offset].toInt() and 0xFF) shl 8) or (data[offset + 1].toInt() and 0xFF)
        val headerBytes = (headerBits + 7) / 8
        val bitsPerHeader = sizeLength + indexLength
        if (bitsPerHeader <= 0) return emptyList()
        val count = headerBits / bitsPerHeader
        var at = offset + 2 + headerBytes
        val end = offset + length
        val units = ArrayList<Pair<Int, Int>>()
        var bit = 0
        for (i in 0 until count) {
            var size = 0
            for (b in 0 until sizeLength) {
                val index = offset + 2 + (bit shr 3)
                val value = (data[index].toInt() shr (7 - (bit and 7))) and 1
                size = (size shl 1) or value
                bit += 1
            }
            bit += indexLength
            if (size <= 0 || at + size > end) break
            units += at to size
            at += size
        }
        return units
    }

    fun config(hex: String?): ByteArray? {
        if (hex.isNullOrEmpty() || hex.length % 2 != 0) return null
        return runCatching { hex.chunked(2).map { it.toInt(16).toByte() }.toByteArray() }.getOrNull()
    }
}
