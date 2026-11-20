package uz.smartsurveillance.tv.v380

const val CMD_AUTH = 1167L
const val CMD_AUTH_REPLY = 1168L
const val CMD_LOGIN = 301L
const val CMD_LOGIN_REPLY = 401L
const val CMD_START = 303L

const val AUTH_OK = 1001L
const val AUTH_BAD_USER = 1011L
const val AUTH_BAD_PASSWORD = 1012L
const val AUTH_BAD_DEVICE = 1018L

const val AUTH_REPLY_SIZE = 256
const val LOGIN_REPLY_MAX = 412

data class AuthReply(val command: Long, val result: Long, val version: Int, val ticket: Long, val session: Long) {
    val ok: Boolean get() = command == CMD_AUTH_REPLY && result == AUTH_OK
}

data class LoginReply(val command: Long, val result: Int, val version: Int, val width: Long, val height: Long) {
    val ok: Boolean get() = command == CMD_LOGIN_REPLY && result != -11 && result != -12
}

object Packets {
    fun auth(deviceId: Long, user: String, encryptedPassword: ByteArray): ByteArray {
        val packet = ByteArray(520)
        packet.put32(0, CMD_AUTH)
        packet.put32(4, 120)
        packet[8] = 31
        packet.put32(9, 1)
        packet.put32(13, deviceId)
        packet.putAscii(49, user, 32)
        encryptedPassword.copyInto(packet, 81, 0, minOf(encryptedPassword.size, 64))
        return packet
    }

    fun parseAuth(reply: ByteArray): AuthReply? {
        if (reply.size < 21) return null
        return AuthReply(
            command = reply.u32(0),
            result = reply.u32(4),
            version = reply[12].toInt() and 0xFF,
            ticket = reply.u32(13),
            session = reply.u32(17),
        )
    }

    fun login(deviceId: Long, ticket: Long, hd: Boolean, audio: Boolean): ByteArray {
        val packet = ByteArray(256)
        packet.put32(0, CMD_LOGIN)
        packet.put32(4, deviceId)
        packet.put32(8, 0)
        packet.put16(12, 20)
        packet.put32(14, ticket)
        packet.put32(22, if (audio) 4097L else 4096L)
        packet.put32(26, if (hd) 1L else 0L)
        return packet
    }

    fun parseLogin(reply: ByteArray): LoginReply? {
        if (reply.size < 8) return null
        val long = reply.size >= 18
        return LoginReply(
            command = reply.u32(0),
            result = reply.i32(4),
            version = if (reply.size >= 10) reply.u16(8) else 0,
            width = if (long) reply.u32(10) else 0,
            height = if (long) reply.u32(14) else 0,
        )
    }

    fun start(): ByteArray {
        val packet = ByteArray(256)
        packet.put32(0, CMD_START)
        packet.put16(4, 0x3001)
        return packet
    }

    fun authError(result: Long): String = when (result) {
        AUTH_BAD_USER -> "Wrong user name"
        AUTH_BAD_PASSWORD -> "Wrong password"
        AUTH_BAD_DEVICE -> "Wrong device id"
        else -> "Login refused ($result)"
    }
}
