package uz.smartsurveillance.tv.v380

fun ByteArray.u16(at: Int): Int = (this[at].toInt() and 0xFF) or ((this[at + 1].toInt() and 0xFF) shl 8)

fun ByteArray.u32(at: Int): Long = (u16(at).toLong()) or (u16(at + 2).toLong() shl 16)

fun ByteArray.i32(at: Int): Int = u32(at).toInt()

fun ByteArray.u64(at: Int): Long = u32(at) or (u32(at + 4) shl 32)

fun ByteArray.put16(at: Int, value: Int) {
    this[at] = value.toByte()
    this[at + 1] = (value shr 8).toByte()
}

fun ByteArray.put32(at: Int, value: Long) {
    for (i in 0 until 4) this[at + i] = (value shr (i * 8)).toByte()
}

fun ByteArray.put64(at: Int, value: Long) {
    for (i in 0 until 8) this[at + i] = (value shr (i * 8)).toByte()
}

fun ByteArray.putAscii(at: Int, text: String, max: Int) {
    val bytes = text.toByteArray(Charsets.US_ASCII)
    bytes.copyInto(this, at, 0, minOf(bytes.size, max))
}

fun ByteArray.hex(): String = joinToString("") { "%02x".format(it.toInt() and 0xFF) }

fun hexBytes(text: String): ByteArray = text.chunked(2).map { it.toInt(16).toByte() }.toByteArray()
