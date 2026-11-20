package uz.smartsurveillance.tv.v380

/** Reads the unsigned byte at [offset], or 0 past the end of the array. */
fun ByteArray.u8(offset: Int): Int = if (offset in indices) this[offset].toInt() and 0xFF else 0

/** Reads the little-endian unsigned 16-bit integer at [offset], with missing bytes read as zero. */
fun ByteArray.u16(offset: Int): Int = u8(offset) or (u8(offset + 1) shl 8)

/** Reads the little-endian unsigned 32-bit integer at [offset], with missing bytes read as zero. */
fun ByteArray.u32(offset: Int): Long =
    (u8(offset).toLong()) or (u8(offset + 1).toLong() shl 8) or (u8(offset + 2).toLong() shl 16) or
        (u8(offset + 3).toLong() shl 24)

/** Reads the little-endian signed 32-bit integer at [offset], with missing bytes read as zero. */
fun ByteArray.i32(offset: Int): Int = u32(offset).toInt()

/** Reads the little-endian unsigned 64-bit integer at [offset] as a signed Long holding the same bits. */
fun ByteArray.u64(offset: Int): Long = u32(offset) or (u32(offset + 4) shl 32)

/** Writes [value] as one byte at [offset]. */
fun ByteArray.put8(offset: Int, value: Int) {
    this[offset] = value.toByte()
}

/** Writes the low 16 bits of [value] little-endian at [offset]. */
fun ByteArray.put16(offset: Int, value: Int) {
    this[offset] = value.toByte()
    this[offset + 1] = (value ushr 8).toByte()
}

/** Writes the low 32 bits of [value] little-endian at [offset]. */
fun ByteArray.put32(offset: Int, value: Long) {
    for (i in 0 until 4) this[offset + i] = (value ushr (8 * i)).toByte()
}

/** Writes the 64 bits of [value] little-endian at [offset]. */
fun ByteArray.put64(offset: Int, value: Long) {
    for (i in 0 until 8) this[offset + i] = (value ushr (8 * i)).toByte()
}

/** Copies the ASCII bytes of [text] into a zero-padded field of [size] bytes at [offset], truncating longer text. */
fun ByteArray.putText(offset: Int, size: Int, text: String) {
    val bytes = text.toByteArray(Charsets.US_ASCII)
    bytes.copyInto(this, offset, 0, minOf(bytes.size, size))
}

/** Formats the bytes as lowercase hexadecimal without separators. */
fun ByteArray.hex(): String = joinToString("") { "%02x".format(it.toInt() and 0xFF) }

/** Parses hexadecimal text, ignoring spaces, into bytes. */
fun unhex(text: String): ByteArray {
    val clean = text.filterNot { it.isWhitespace() }
    require(clean.length % 2 == 0) { "Odd number of hex digits" }
    return ByteArray(clean.length / 2) { clean.substring(it * 2, it * 2 + 2).toInt(16).toByte() }
}

/** Finds the first occurrence of the three bytes 00 00 01 at or after [from], or -1. */
internal fun ByteArray.findStartCode(from: Int, until: Int = size): Int {
    var i = maxOf(from, 0)
    val end = minOf(until, size) - 3
    while (i <= end) {
        if (this[i].toInt() == 0 && this[i + 1].toInt() == 0 && this[i + 2].toInt() == 1) return i
        i += 1
    }
    return -1
}
