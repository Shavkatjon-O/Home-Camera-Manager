package uz.smartsurveillance.tv.v380

import java.io.Closeable
import java.io.IOException
import java.io.InputStream
import java.net.ConnectException
import java.net.InetSocketAddress
import java.net.NoRouteToHostException
import java.net.Socket
import java.net.SocketTimeoutException
import javax.crypto.Cipher

class V380Exception(message: String, val unreachable: Boolean = false, val refused: Boolean = false) : IOException(message)

data class Session(val version: Int, val communication: Int, val width: Long, val height: Long, val encrypted: Boolean, val ticket: Long)

interface ClientListener {
    fun onSession(session: Session)
    fun onBytes(count: Int)
    fun onVideo(frame: MediaFrame)
    fun onAudio(frame: MediaFrame)
}

class Client(
    private val host: String,
    private val port: Int,
    private val deviceId: Long,
    private val user: String,
    private val password: String,
    private val hd: Boolean,
    private val audio: Boolean,
    private val listener: ClientListener,
) : Closeable {
    @Volatile
    private var socket: Socket? = null

    @Volatile
    private var streaming: Socket? = null

    @Volatile
    private var closed = false

    private val writeLock = Any()

    fun run() {
        val auth = authenticate()
        val stream = open()
        try {
            stream.soTimeout = 0
            write(stream, Packets.login(deviceId, auth.ticket, hd, audio))
            val reply = receive(stream.getInputStream(), LOGIN_REPLY_MAX, 5000, 200)
            val login = reply?.let { Packets.parseLogin(it) } ?: throw V380Exception("No stream login reply")
            if (login.command != CMD_LOGIN_REPLY) throw V380Exception("Unexpected stream reply ${login.command}")
            if (!login.ok) throw V380Exception("Stream login refused (${login.result})", refused = true)
            val encrypted = auth.version > 30
            listener.onSession(Session(auth.version, login.version, login.width, login.height, encrypted, auth.ticket))
            write(stream, Packets.start())
            streaming = stream
            receiveFrames(stream, if (encrypted) Crypto.decryptor(Crypto.mediaKey(auth.ticket)) else null, login.version)
        } finally {
            close()
        }
    }

    fun send(packet: ByteArray): Boolean {
        val current = streaming ?: return false
        return try {
            write(current, packet)
            true
        } catch (_: IOException) {
            false
        }
    }

    override fun close() {
        closed = true
        streaming = null
        runCatching { socket?.close() }
    }

    private fun authenticate(): AuthReply {
        val auth = connect()
        try {
            write(auth, Packets.auth(deviceId, user, Crypto.password(password)))
            val reply = receive(auth.getInputStream(), AUTH_REPLY_SIZE, 5000, 300)
            val parsed = reply?.let { Packets.parseAuth(it) } ?: throw V380Exception("No login reply")
            if (parsed.command != CMD_AUTH_REPLY) throw V380Exception("Unexpected login reply ${parsed.command}")
            if (!parsed.ok) throw V380Exception(Packets.authError(parsed.result), refused = true)
            return parsed
        } finally {
            runCatching { auth.close() }
        }
    }

    private fun open(): Socket {
        val stream = Socket().apply {
            tcpNoDelay = true
            receiveBufferSize = 0x20000
            sendBufferSize = 0x10000
        }
        socket = stream
        if (closed) throw V380Exception("Closed")
        connectSocket(stream)
        return stream
    }

    private fun connect(): Socket {
        val auth = Socket()
        socket = auth
        if (closed) throw V380Exception("Closed")
        connectSocket(auth)
        return auth
    }

    private fun connectSocket(target: Socket) {
        try {
            target.connect(InetSocketAddress(host, port), CONNECT_TIMEOUT_MS)
        } catch (error: SocketTimeoutException) {
            throw V380Exception("No answer at $host:$port", unreachable = true)
        } catch (error: ConnectException) {
            throw V380Exception("Refused at $host:$port", unreachable = true)
        } catch (error: NoRouteToHostException) {
            throw V380Exception("No route to $host", unreachable = true)
        } catch (error: IOException) {
            if (closed) throw V380Exception("Closed")
            throw V380Exception("Cannot reach $host:$port", unreachable = true)
        }
    }

    private fun write(target: Socket, packet: ByteArray) {
        synchronized(writeLock) {
            val out = target.getOutputStream()
            out.write(packet)
            out.flush()
        }
    }

    private fun receive(input: InputStream, max: Int, timeoutMs: Int, idleMs: Int): ByteArray? {
        val target = socket ?: return null
        val buffer = ByteArray(max)
        var total = 0
        val deadline = System.currentTimeMillis() + timeoutMs
        while (total < max) {
            val left = deadline - System.currentTimeMillis()
            if (left <= 0) break
            target.soTimeout = if (total == 0) left.toInt() else idleMs
            val read = try {
                input.read(buffer, total, max - total)
            } catch (_: SocketTimeoutException) {
                break
            }
            if (read <= 0) break
            total += read
        }
        return if (total == 0) null else buffer.copyOf(total)
    }

    private fun receiveFrames(stream: Socket, cipher: Cipher?, communication: Int) {
        stream.soTimeout = SILENCE_MS
        val input = stream.getInputStream()
        val header = ByteArray(HEADER_SIZE)
        var payload = ByteArray(MAX_FRAGMENT)
        val assembler = Assembler()
        var badInRow = 0
        while (!closed) {
            readFully(input, header, HEADER_SIZE)
            listener.onBytes(HEADER_SIZE)
            val fragment = parseFragment(header)
            if (fragment == null || !fragment.valid) {
                badInRow += 1
                if (badInRow > MAX_BAD_HEADERS) throw V380Exception("Stream out of sync")
                continue
            }
            badInRow = 0
            if (payload.size < fragment.length) payload = ByteArray(fragment.length)
            readFully(input, payload, fragment.length)
            listener.onBytes(fragment.length)
            if (fragment.kind == FrameKind.Other) continue
            val frame = assembler.add(fragment, payload) ?: continue
            if (fragment.kind == FrameKind.Video) {
                video(frame, cipher, communication)
            } else {
                if (cipher != null) {
                    Crypto.decryptAligned(cipher, frame.payload, 0, frame.payload.size)
                }
                listener.onAudio(frame)
            }
        }
    }

    private fun video(frame: MediaFrame, cipher: Cipher?, communication: Int) {
        if (cipher != null) {
            if (communication == 21) {
                Crypto.decryptAligned(cipher, frame.payload, 0, frame.payload.size)
            } else {
                Crypto.decryptVideo(cipher, frame.payload, 0, frame.payload.size)
            }
        }
        val trimmed = AnnexB.trim(frame.payload) ?: return
        listener.onVideo(MediaFrame(frame.type, frame.id, frame.frameType, frame.rate, frame.timestamp, trimmed))
    }

    private fun readFully(input: InputStream, buffer: ByteArray, length: Int) {
        var total = 0
        while (total < length) {
            val read = try {
                input.read(buffer, total, length - total)
            } catch (_: SocketTimeoutException) {
                throw V380Exception("No data for ${SILENCE_MS / 1000} s")
            }
            if (read < 0) throw V380Exception("Camera closed the stream")
            total += read
        }
    }

    private companion object {
        const val CONNECT_TIMEOUT_MS = 5000
        const val SILENCE_MS = 15000
        const val MAX_BAD_HEADERS = 64
    }
}
