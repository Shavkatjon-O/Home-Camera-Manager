package uz.smartsurveillance.tv.v380

import java.io.ByteArrayOutputStream
import java.io.EOFException
import java.io.IOException
import java.io.InputStream
import java.net.InetSocketAddress
import java.net.Socket
import java.net.SocketTimeoutException
import java.security.SecureRandom
import java.util.Random
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit

/**
 * What a session learned about the camera and its stream.
 *
 * @property deviceVersion Device version from the login reply.
 * @property communicationVersion Communication version from the stream login reply.
 * @property replySize Length of the stream login reply the camera sent.
 * @property reportedSize Picture size from the stream login reply, a fallback when no SPS can be parsed.
 * @property codec Video codec, once the first key frame identified it.
 * @property size Picture size from the SPS of the first key frame.
 * @property frameRate Frame rate the frame headers report.
 * @property audio Audio format, once the first audio frame arrived.
 * @property dropped Frames dropped for a missing fragment or a missing start code.
 */
data class SessionFacts(
    val deviceVersion: Int,
    val communicationVersion: Int,
    val replySize: Int,
    val reportedSize: VideoSize?,
    val codec: Codec? = null,
    val size: VideoSize? = null,
    val frameRate: Int? = null,
    val audio: String? = null,
    val dropped: Int = 0,
)

/**
 * One V380 session over the LAN protocol: login, stream login, start, then media until the session ends.
 *
 * [run] blocks on the calling thread and throws [V380Exception] when the session fails; the caller reconnects with
 * back-off, and every reconnect logs in again. Control records are written by a writer thread in the order given.
 */
class V380Client(private val config: Config, private val listener: Listener) {
    /**
     * Where and how to connect.
     *
     * @property host Camera address.
     * @property port Camera TCP port.
     * @property deviceId Device id from the camera's label.
     * @property user User name.
     * @property password Password.
     * @property stream Main or sub stream.
     * @property sound Whether to ask for audio.
     * @property connectTimeoutMs Timeout of each TCP connect.
     * @property replyTimeoutMs Time to wait for the first byte of a reply.
     * @property idleGapMs Silence after the first byte that ends a reply.
     * @property silenceMs Media silence after which the session counts as lost.
     * @property random Source of the login's random key.
     */
    data class Config(
        val host: String,
        val port: Int = DEFAULT_PORT,
        val deviceId: Long,
        val user: String = "admin",
        val password: String,
        val stream: StreamKind = StreamKind.Sub,
        val sound: Boolean = false,
        val connectTimeoutMs: Int = 5000,
        val replyTimeoutMs: Int = 5000,
        val idleGapMs: Int = 250,
        val silenceMs: Int = 15000,
        val random: Random = SecureRandom(),
    )

    /** Receives what the session produces, on the thread that runs it. */
    interface Listener {
        /** The camera accepted the stream login; media follows the start request. */
        fun onSession(facts: SessionFacts) {}

        /** Bytes arrived on the stream connection. */
        fun onBytes(count: Int) {}

        /** A decrypted, aligned access unit in Annex-B format, starting with the first key frame of the session. */
        fun onVideo(codec: Codec, data: ByteArray, key: Boolean) {}

        /** A decrypted audio payload of a frame type of [FrameType], only when sound was asked for. */
        fun onAudio(type: Int, payload: ByteArray) {}
    }

    @Volatile
    private var closed = false

    @Volatile
    private var loginSocket: Socket? = null

    @Volatile
    private var streamSocket: Socket? = null

    @Volatile
    private var writer: Thread? = null

    @Volatile
    private var moving = false

    private val outbox = LinkedBlockingQueue<ByteArray>()
    private val reassembler = Reassembler()

    /** The latest facts of the session, or null before the stream login was accepted. */
    @Volatile
    var facts: SessionFacts? = null
        private set

    /** Whether a PTZ move is running. */
    val isMoving: Boolean get() = moving

    /**
     * Runs the session until it ends.
     *
     * @throws V380Exception The camera is unreachable, refused, sent something invalid, went silent or closed.
     */
    fun run() {
        try {
            val login = login()
            if (closed) return
            stream(login)
        } catch (error: V380Exception) {
            if (!closed) throw error
        } catch (error: IOException) {
            if (!closed) throw V380Exception(error.message ?: "Connection failed", cause = error)
        } finally {
            shutdown()
        }
    }

    /**
     * Queues a 16-byte control record for the stream connection.
     *
     * @return False when the session is closed.
     */
    fun command(record: ByteArray): Boolean {
        if (closed) return false
        outbox.offer(record.copyOf())
        return true
    }

    /** Starts a pan or tilt move, or stops the running one; a move lasts until a stop. */
    fun move(move: PtzMove) {
        if (closed) return
        moving = move != PtzMove.Stop
        command(move.record())
    }

    /** Ends the session, sending a stop first when a move is running. */
    fun close() {
        if (closed) return
        closed = true
        val current = writer
        if (current != null && current.isAlive) {
            outbox.offer(CLOSE)
            Thread({
                runCatching { current.join(CLOSE_GRACE_MS) }
                closeSockets()
            }, "v380-close").apply { isDaemon = true }.start()
        } else {
            closeSockets()
        }
    }

    private fun login(): LoginReply {
        val socket = connect { loginSocket = it }
        try {
            val field = Crypto.passwordField(config.password, Crypto.randomKey(config.random))
            socket.getOutputStream().apply {
                write(Records.login(config.deviceId, config.user, field))
                flush()
            }
            val reply = Records.loginReply(readReply(socket, Records.LOGIN_REPLY_SIZE, "login"))
            if (!reply.accepted) {
                throw V380Exception(Records.refusal(reply.result), refused = true, retryAfterMs = REFUSED_LOGIN_RETRY_MS)
            }
            return reply
        } finally {
            runCatching { socket.close() }
            loginSocket = null
        }
    }

    private fun stream(login: LoginReply) {
        val socket = connect(stream = true) { streamSocket = it }
        if (closed) return
        val output = socket.getOutputStream()
        output.write(Records.streamLogin(config.deviceId, login.ticket, config.stream, config.sound))
        output.flush()
        val reply = Records.streamReply(readReply(socket, Records.STREAM_REPLY_SIZE, "stream login"))
        if (reply.refused) throw V380Exception("Stream refused with code ${reply.result}", refused = true)
        val cipher = MediaCipher.forSession(login.deviceVersion, reply.communicationVersion, login.ticket)
        val first = SessionFacts(login.deviceVersion, reply.communicationVersion, reply.length, reply.size)
        facts = first
        listener.onSession(first)
        output.write(Records.start())
        output.flush()
        startWriter(socket)
        media(socket, cipher)
    }

    private fun connect(stream: Boolean = false, register: (Socket) -> Unit): Socket {
        val socket = Socket()
        register(socket)
        if (closed) socket.close()
        try {
            if (stream) {
                socket.receiveBufferSize = RECEIVE_BUFFER
                socket.sendBufferSize = SEND_BUFFER
                socket.tcpNoDelay = true
            }
            socket.connect(InetSocketAddress(config.host, config.port), config.connectTimeoutMs)
            return socket
        } catch (error: IOException) {
            runCatching { socket.close() }
            if (closed) throw V380Exception("Closed")
            throw V380Exception(
                "Camera does not answer at ${config.host}:${config.port}",
                unreachable = true,
                cause = error,
            )
        } catch (error: IllegalArgumentException) {
            runCatching { socket.close() }
            throw V380Exception("Invalid camera address ${config.host}", unreachable = true, cause = error)
        }
    }

    private fun readReply(socket: Socket, max: Int, what: String): ByteArray {
        val input = socket.getInputStream()
        val out = ByteArrayOutputStream(max)
        val buffer = ByteArray(max)
        socket.soTimeout = config.replyTimeoutMs
        while (out.size() < max) {
            val count = try {
                input.read(buffer, 0, max - out.size())
            } catch (_: SocketTimeoutException) {
                if (out.size() == 0) throw V380Exception("No $what reply within ${config.replyTimeoutMs / 1000} s")
                break
            }
            if (count < 0) break
            out.write(buffer, 0, count)
            socket.soTimeout = config.idleGapMs
        }
        if (out.size() == 0) throw V380Exception("The camera closed the connection without a $what reply")
        return out.toByteArray()
    }

    private fun media(socket: Socket, cipher: MediaCipher) {
        socket.soTimeout = config.silenceMs
        val input = socket.getInputStream().buffered(INPUT_BUFFER)
        val state = MediaState(cipher)
        val header = ByteArray(FragmentHeader.SIZE)
        try {
            readFully(input, header, header.size)
            var scanned = 0
            while (!closed) {
                val parsed = FragmentHeader.parse(header)?.takeIf { scanned == 0 || FrameType.isKnown(it.type) }
                if (parsed == null) {
                    scanned += 1
                    if (scanned > MAX_SCAN_BYTES) throw V380Exception("Lost the fragment framing")
                    state.lostFraming()
                    header.copyInto(header, 0, 1, header.size)
                    header[header.size - 1] = readByte(input)
                    continue
                }
                scanned = 0
                val payload = ByteArray(parsed.length)
                readFully(input, payload, payload.size)
                listener.onBytes(FragmentHeader.SIZE + payload.size)
                reassembler.push(parsed, payload)?.let { state.frame(it) }
                readFully(input, header, header.size)
            }
        } catch (_: SocketTimeoutException) {
            throw V380Exception("No media for ${config.silenceMs / 1000} s")
        } catch (_: EOFException) {
            throw V380Exception("The camera closed the stream")
        }
    }

    private inner class MediaState(private val cipher: MediaCipher) {
        private var codec: Codec? = null
        private var family: Codec? = null
        private var waitKey = true
        private var unaligned = 0
        private val audioSeen = HashSet<Int>()

        fun lostFraming() {
            waitKey = true
        }

        fun frame(frame: Frame) {
            val data = frame.data
            val payload = data.copyOfRange(FrameHeader.SIZE, data.size)
            when {
                FrameType.isVideo(frame.type) -> video(frame, payload)
                FrameType.isAudio(frame.type) -> audio(frame.type, payload)
            }
        }

        private fun video(frame: Frame, payload: ByteArray) {
            cipher.video(payload)
            val aligned = AnnexB.align(payload)
            if (aligned == null) {
                unaligned += 1
                update { it.copy(dropped = reassembler.dropped + unaligned) }
                return
            }
            val key = FrameType.isKey(frame.type)
            val known = codec
            if (known == null) {
                if (!key) return
                val found = AnnexB.codecOf(aligned) ?: return
                codec = found
                family = FrameType.codec(frame.type)
                val sets = AnnexB.parameterSets(aligned, found)
                val size = when {
                    sets == null -> null
                    found == Codec.Hevc -> Sps.hevcSize(sets[1].bytes)
                    else -> Sps.avcSize(sets[0].bytes)
                }
                update { it.copy(codec = found, size = size, frameRate = frame.header.rate.takeIf { rate -> rate > 0 }) }
            } else {
                if (FrameType.codec(frame.type) != family) return
                if (key && AnnexB.codecOf(aligned).let { it != null && it != known }) return
            }
            if (waitKey && !key) return
            waitKey = false
            update { it.copy(dropped = reassembler.dropped + unaligned) }
            listener.onVideo(codec ?: return, aligned, key)
        }

        private fun audio(type: Int, payload: ByteArray) {
            if (!config.sound) return
            cipher.audio(payload)
            if (audioSeen.add(type)) update { it.copy(audio = audioName(type)) }
            listener.onAudio(type, payload)
        }
    }

    private inline fun update(change: (SessionFacts) -> SessionFacts) {
        val current = facts ?: return
        val next = change(current)
        if (next != current) facts = next
    }

    private fun startWriter(socket: Socket) {
        val output = socket.getOutputStream()
        writer = Thread({
            var running = false
            try {
                while (true) {
                    val record = outbox.poll(WRITER_POLL_MS, TimeUnit.MILLISECONDS) ?: if (closed && outbox.isEmpty()) {
                        CLOSE
                    } else {
                        continue
                    }
                    if (record === CLOSE) {
                        if (running) output.write(PtzMove.Stop.record())
                        output.flush()
                        break
                    }
                    output.write(record)
                    output.flush()
                    if (record.u32(0) == PTZ_CODE) running = !record.contentEquals(PtzMove.Stop.record())
                }
            } catch (_: IOException) {
            } catch (_: InterruptedException) {
            }
        }, "v380-writer").apply {
            isDaemon = true
            start()
        }
    }

    private fun shutdown() {
        val current = writer
        if (current != null && current.isAlive && !closed) {
            closed = true
            outbox.offer(CLOSE)
            runCatching { current.join(CLOSE_GRACE_MS) }
        }
        closed = true
        closeSockets()
    }

    private fun closeSockets() {
        runCatching { loginSocket?.close() }
        runCatching { streamSocket?.close() }
        writer?.interrupt()
    }

    /** Defaults and limits of a session. */
    companion object {
        /** Default TCP port of the cameras. */
        const val DEFAULT_PORT = 8800

        /** Shortest wait before logging in again after the camera refused the credentials. */
        const val REFUSED_LOGIN_RETRY_MS = 60_000L

        private const val RECEIVE_BUFFER = 128 * 1024
        private const val SEND_BUFFER = 64 * 1024
        private const val INPUT_BUFFER = 64 * 1024
        private const val MAX_SCAN_BYTES = 64 * 1024
        private const val CLOSE_GRACE_MS = 500L
        private const val WRITER_POLL_MS = 200L
        private const val PTZ_CODE = 0xAAL
        private val CLOSE = ByteArray(0)

        /** Names an audio frame type. */
        fun audioName(type: Int): String = when (type) {
            FrameType.ADPCM -> "IMA ADPCM 8 kHz mono"
            FrameType.AAC -> "AAC in ADTS"
            FrameType.ALAW -> "G.711 A-law 8 kHz mono"
            else -> "Unknown audio type 0x%02x".format(type)
        }

        private fun readFully(input: InputStream, into: ByteArray, count: Int) {
            var at = 0
            while (at < count) {
                val read = input.read(into, at, count - at)
                if (read < 0) throw EOFException()
                at += read
            }
        }

        private fun readByte(input: InputStream): Byte {
            val value = input.read()
            if (value < 0) throw EOFException()
            return value.toByte()
        }
    }
}
