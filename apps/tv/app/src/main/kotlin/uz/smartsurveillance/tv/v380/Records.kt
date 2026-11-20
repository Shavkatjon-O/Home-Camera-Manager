package uz.smartsurveillance.tv.v380

/** Fixed-size control-plane records the client sends and the replies it reads. */
object Records {
    /** Login request command. */
    const val LOGIN = 1167

    /** Login reply command. */
    const val LOGIN_REPLY = 1168

    /** Stream login request command. */
    const val STREAM_LOGIN = 301

    /** Stream login reply command. */
    const val STREAM_LOGIN_REPLY = 401

    /** Start request command. */
    const val START = 303

    /** Size of a login request. */
    const val LOGIN_SIZE = 520

    /** Largest login reply. */
    const val LOGIN_REPLY_SIZE = 256

    /** Shortest login reply a client accepts. */
    const val LOGIN_REPLY_MIN = 21

    /** Size of a stream login request and of a start request. */
    const val REQUEST_SIZE = 256

    /** Largest stream login reply. */
    const val STREAM_REPLY_SIZE = 412

    /** Shortest stream login reply a client accepts. */
    const val STREAM_REPLY_MIN = 8

    /** Login result that accepts the login. */
    const val ACCEPTED = 1001

    private const val SOUND_ON = 4097L
    private const val SOUND_OFF = 4096L
    private const val START_FLAG = 0x3001

    /**
     * Builds the 520-byte login request.
     *
     * @param deviceId Device id from the camera's label.
     * @param user User name, admin on these cameras.
     * @param passwordField The 64-byte encrypted password field.
     */
    fun login(deviceId: Long, user: String, passwordField: ByteArray): ByteArray {
        require(passwordField.size == Crypto.PASSWORD_FIELD_SIZE) { "The password field is 64 bytes" }
        val out = ByteArray(LOGIN_SIZE)
        out.put32(0, LOGIN.toLong())
        out.put32(4, 120)
        out.put8(8, 31)
        out.put32(9, 1)
        out.put32(13, deviceId)
        out.putText(49, 32, user)
        passwordField.copyInto(out, 81)
        return out
    }

    /**
     * Builds the 256-byte stream login request.
     *
     * @param deviceId Device id.
     * @param ticket Ticket from the login reply.
     * @param stream Main or sub stream.
     * @param sound Whether to ask for audio.
     */
    fun streamLogin(deviceId: Long, ticket: Long, stream: StreamKind, sound: Boolean): ByteArray {
        val out = ByteArray(REQUEST_SIZE)
        out.put32(0, STREAM_LOGIN.toLong())
        out.put32(4, deviceId)
        out.put16(12, 20)
        out.put32(14, ticket)
        out.put32(22, if (sound) SOUND_ON else SOUND_OFF)
        out.put32(26, stream.value)
        return out
    }

    /** Builds the 256-byte start request. */
    fun start(): ByteArray {
        val out = ByteArray(REQUEST_SIZE)
        out.put32(0, START.toLong())
        out.put16(4, START_FLAG)
        return out
    }

    /**
     * Reads a login reply.
     *
     * @param data The bytes received, at least 21 of them.
     * @return The parsed reply.
     * @throws V380Exception The reply is short or carries another command.
     */
    fun loginReply(data: ByteArray): LoginReply {
        if (data.size < LOGIN_REPLY_MIN) throw V380Exception("Login reply of ${data.size} bytes is too short")
        val command = data.u32(0).toInt()
        if (command != LOGIN_REPLY) throw V380Exception("Login reply carries command $command")
        return LoginReply(
            result = data.i32(4),
            deviceVersion = data.u8(12),
            ticket = data.u32(13),
            sessionId = data.u32(17),
        )
    }

    /**
     * Reads a stream login reply.
     *
     * @param data The bytes received, at least 8 of them; missing fields read as zero.
     * @return The parsed reply.
     * @throws V380Exception The reply is short or carries another command.
     */
    fun streamReply(data: ByteArray): StreamReply {
        if (data.size < STREAM_REPLY_MIN) throw V380Exception("Stream login reply of ${data.size} bytes is too short")
        val command = data.u32(0).toInt()
        if (command != STREAM_LOGIN_REPLY) throw V380Exception("Stream login reply carries command $command")
        return StreamReply(
            result = data.i32(4),
            communicationVersion = data.u16(8),
            width = data.u32(10),
            height = data.u32(14),
            length = data.size,
        )
    }

    /** Explains a login result other than 1001. */
    fun refusal(result: Int): String = when (result) {
        1011 -> "Unknown user name"
        1012 -> "Wrong password"
        1018 -> "Wrong device id"
        else -> "Login refused with code $result"
    }
}

/**
 * The fields of a login reply a client uses.
 *
 * @property result Result code, 1001 when accepted.
 * @property deviceVersion Device version, which selects the media encryption.
 * @property ticket Ticket that the stream login carries and the media key derives from.
 * @property sessionId Session id, unused on the LAN.
 */
data class LoginReply(val result: Int, val deviceVersion: Int, val ticket: Long, val sessionId: Long) {
    /** Whether the camera accepted the login. */
    val accepted: Boolean get() = result == Records.ACCEPTED
}

/**
 * The fields of a stream login reply.
 *
 * @property result Result; -11 and -12 refuse, every other value accepts.
 * @property communicationVersion Communication version, 21 switches video to whole-block decryption.
 * @property width Picture width the camera reports, a fallback when no SPS can be parsed.
 * @property height Picture height the camera reports.
 * @property length Number of bytes the camera sent.
 */
data class StreamReply(
    val result: Int,
    val communicationVersion: Int,
    val width: Long,
    val height: Long,
    val length: Int,
) {
    /** Whether the camera refused the stream. */
    val refused: Boolean get() = result == -11 || result == -12

    /** The reported size, or null when it is missing or implausible. */
    val size: VideoSize?
        get() = if (width in 16..8192 && height in 16..8192) VideoSize(width.toInt(), height.toInt()) else null
}

/** A pan or tilt move of a PTZ camera, or the stop that ends one. */
enum class PtzMove(private val pan: Int, private val tilt: Int) {
    /** Turn left. */
    Left(1001, 1000),

    /** Turn right. */
    Right(1002, 1000),

    /** Tilt up. */
    Up(1000, 1003),

    /** Tilt down. */
    Down(1000, 1004),

    /** End the running move. */
    Stop(1000, 1000);

    /** The 16-byte PTZ record of this move. */
    fun record(): ByteArray {
        val out = ByteArray(Commands.SIZE)
        out.put32(0, 0xAA)
        out.put16(4, 1000)
        out.put16(6, 1000)
        out.put16(8, pan)
        out.put16(10, tilt)
        out.put16(14, 1)
        return out
    }
}

/** Light, siren and picture records, all written on the stream connection while media flows. */
object Commands {
    /** Size of every control record. */
    const val SIZE = 16

    /** Interval at which siren on is repeated for as long as the siren should sound. */
    const val SIREN_REPEAT_MS = 500L

    private const val LIGHT = 0xC4L
    private const val SIREN = 0xB9L
    private const val PICTURE = 0xC5L
    private const val FLIP = 0xBEL

    /** Light modes. */
    enum class Light(internal val value: Long) {
        /** Light on. */
        On(1001),

        /** Light off. */
        Off(1002),

        /** Light switched by the camera. */
        Auto(1003),
    }

    /** Picture modes. */
    enum class Picture(internal val value: Long) {
        /** Colour picture. */
        Colour(1001),

        /** Black and white picture. */
        BlackAndWhite(1002),

        /** Picture mode chosen by the camera. */
        Auto(1003),
    }

    /** The record that switches the light. */
    fun light(mode: Light): ByteArray = record(LIGHT, mode.value, 256)

    /** The record that sounds the siren once; repeat it every [SIREN_REPEAT_MS] while it should sound. */
    fun sirenOn(): ByteArray = record(SIREN, 1001, 2)

    /** The record that silences the siren. */
    fun sirenOff(): ByteArray = record(SIREN, 1002, 1)

    /** The record that sets the picture mode. */
    fun picture(mode: Picture): ByteArray = record(PICTURE, mode.value, 256)

    /** The record that turns the picture by 180 degrees. */
    fun flip(): ByteArray = record(FLIP, 1000, 0)

    private fun record(code: Long, value: Long, second: Long): ByteArray {
        val out = ByteArray(SIZE)
        out.put32(0, code)
        out.put32(4, value)
        out.put32(8, second)
        return out
    }
}
