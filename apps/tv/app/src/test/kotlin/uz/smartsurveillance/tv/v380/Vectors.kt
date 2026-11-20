package uz.smartsurveillance.tv.v380

import java.io.ByteArrayOutputStream
import java.security.MessageDigest

fun sha256(data: ByteArray): String = MessageDigest.getInstance("SHA-256").digest(data).hex()

fun counting(count: Int, from: Int = 0): ByteArray = ByteArray(count) { ((from + it) and 0xFF).toByte() }

object Transcript {
    const val DEVICE_ID = 12345678L
    const val PASSWORD = "secret123"
    const val TICKET = 0x0badf00dL
    const val DEVICE_VERSION = 32
    const val COMMUNICATION_VERSION = 20

    private val START = byteArrayOf(0, 0, 0, 1)

    val vps = unhex("40010c01ffff01400000030090000003000003005a95980900")
    val subSps = unhex(
        "42010101400000030090000003000003005aa0050200b459e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104",
    )
    val pps = unhex("4401c172b46240")

    val keyUnit: ByteArray = START + vps + START + subSps + START + pps + START + byteArrayOf(0x26, 0x01) + counting(300)
    val nonKeySent: ByteArray = byteArrayOf(0xAB.toByte(), 0xCD.toByte()) + START + byteArrayOf(0x02, 0x01) + counting(120)
    val adpcm: ByteArray = unhex("e8030a00") + counting(252)
    val adts: ByteArray = unhex("fff96c4020fffc") + counting(256)
    val alaw: ByteArray = counting(160)

    class Piece(val type: Int, val count: Int, val index: Int, val payload: ByteArray)

    fun frame(number: Long, inner: Int, rate: Int, timestamp: Long, payload: ByteArray, video: Boolean): ByteArray {
        val cipher = MediaCipher.forSession(DEVICE_VERSION, COMMUNICATION_VERSION, TICKET)
        val body = payload.copyOf()
        if (video) cipher.encryptVideo(body) else cipher.encryptAudio(body)
        return FrameHeader.build(number, inner, rate, timestamp) + body
    }

    fun pieces(): List<Piece> {
        val a = frame(1, 0, 15, 1700000000000, keyUnit, video = true)
        val b = frame(2, 1, 15, 1700000000066, nonKeySent, video = true)
        val c = frame(3, 0, 0, 1700000000070, adpcm, video = false)
        val d = frame(4, 0, 0, 1700000000080, adts, video = false)
        val e = frame(5, 0, 0, 1700000000090, alaw, video = false)
        return listOf(
            Piece(0x28, 3, 0, a.copyOfRange(0, 200)),
            Piece(0x16, 1, 0, c),
            Piece(0x28, 3, 1, a.copyOfRange(200, 400)),
            Piece(0x5B, 1, 0, counting(8)),
            Piece(0x28, 3, 2, a.copyOfRange(400, 421)),
            Piece(0x29, 1, 0, b),
            Piece(0x18, 1, 0, d),
            Piece(0x1A, 2, 0, e.copyOfRange(0, 100)),
            Piece(0x1A, 2, 1, e.copyOfRange(100, 176)),
        )
    }

    fun media(): ByteArray {
        val out = ByteArrayOutputStream()
        for (piece in pieces()) {
            out.write(FragmentHeader.build(piece.type, piece.count, piece.index, piece.payload.size))
            out.write(piece.payload)
        }
        return out.toByteArray()
    }
}
