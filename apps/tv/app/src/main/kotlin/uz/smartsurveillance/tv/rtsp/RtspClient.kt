package uz.smartsurveillance.tv.rtsp

import java.io.BufferedInputStream
import java.io.Closeable
import java.io.IOException
import java.io.InputStream
import java.net.ConnectException
import java.net.InetSocketAddress
import java.net.NoRouteToHostException
import java.net.Socket
import java.net.SocketTimeoutException
import uz.smartsurveillance.tv.v380.Codec

class RtspException(message: String, val unreachable: Boolean = false, val refused: Boolean = false) : IOException(message)

interface RtspListener {
    fun onSession(description: String)
    fun onBytes(count: Int)
    fun onVideo(codec: Codec, data: ByteArray, key: Boolean)
    fun onAudio(config: ByteArray, sampleRate: Int, channels: Int, data: ByteArray, offset: Int, length: Int)
}

class RtspClient(
    private val host: String,
    private val port: Int,
    private val path: String,
    private val user: String,
    private val password: String,
    private val audio: Boolean,
    private val listener: RtspListener,
) : Closeable {
    @Volatile
    private var socket: Socket? = null

    @Volatile
    private var closed = false

    private lateinit var input: InputStream
    private var cseq = 0
    private var challenge: Map<String, String>? = null
    private var nonceCount = 0
    private var session: String? = null
    private val url = "rtsp://$host:$port$path"

    fun run() {
        val target = Socket().apply { tcpNoDelay = true; receiveBufferSize = 0x40000 }
        socket = target
        if (closed) throw RtspException("Closed")
        try {
            target.connect(InetSocketAddress(host, port), CONNECT_TIMEOUT_MS)
        } catch (_: SocketTimeoutException) {
            throw RtspException("No answer at $host:$port", unreachable = true)
        } catch (_: ConnectException) {
            throw RtspException("Refused at $host:$port", unreachable = true)
        } catch (_: NoRouteToHostException) {
            throw RtspException("No route to $host", unreachable = true)
        } catch (error: IOException) {
            if (closed) throw RtspException("Closed")
            throw RtspException("Cannot reach $host:$port", unreachable = true)
        }
        try {
            target.soTimeout = REPLY_TIMEOUT_MS
            input = BufferedInputStream(target.getInputStream(), 64 * 1024)
            play(target)
        } finally {
            close()
        }
    }

    override fun close() {
        closed = true
        runCatching { socket?.close() }
    }

    private fun play(target: Socket) {
        request("OPTIONS", url)
        val described = request("DESCRIBE", url, listOf("Accept" to "application/sdp"))
        val sdp = Sdp.parse(described.body)
        val base = described.header("content-base")?.takeIf { it.startsWith("rtsp://", ignoreCase = true) } ?: url
        val video = sdp.video() ?: throw RtspException("No H.264 or H.265 video in the stream")
        val codec = if (video.codec == "H265") Codec.Hevc else Codec.Avc
        val setup = request("SETUP", Sdp.resolve(base, video.control), listOf("Transport" to "RTP/AVP/TCP;unicast;interleaved=0-1"))
        session = Messages.session(setup.header("session")) ?: throw RtspException("No session from the camera")
        val keepAliveMs = ((Messages.timeoutSeconds(setup.header("session")) ?: 60) * 1000L / 2).coerceIn(5_000L, 30_000L)
        val sound = if (audio) sdp.audio() else null
        val config = sound?.let { AacUnits.config(it.fmtp["config"]) }
        if (sound != null && config != null) {
            request("SETUP", Sdp.resolve(base, sound.control), listOf("Transport" to "RTP/AVP/TCP;unicast;interleaved=2-3"))
        }
        val describedAudio = if (sound != null && config != null) ", audio ${sound.codec.lowercase()} ${sound.clock / 1000.0} kHz" else ""
        listener.onSession("${video.codec}$describedAudio")
        request("PLAY", Sdp.resolve(base, sdp.control), listOf("Range" to "npt=0.000-"))
        target.soTimeout = SILENCE_MS
        val depacketizer = VideoDepacketizer(codec) { data, key -> listener.onVideo(codec, data, key) }
        val sizeLength = sound?.fmtp?.get("sizelength")?.toIntOrNull() ?: 13
        val indexLength = sound?.fmtp?.get("indexlength")?.toIntOrNull() ?: 3
        val rate = sound?.clock ?: 0
        val channels = sound?.channels ?: 1
        var buffer = ByteArray(64 * 1024)
        var lastKeepAlive = System.currentTimeMillis()
        while (!closed) {
            val first = read()
            if (first == '$'.code) {
                val channel = read()
                val length = (read() shl 8) or read()
                if (buffer.size < length) buffer = ByteArray(length)
                readFully(buffer, length)
                listener.onBytes(length + 4)
                val rtp = if (channel == 0 || channel == 2) parseRtp(buffer, length) else null
                if (rtp != null && channel == 0) {
                    depacketizer.push(buffer, rtp)
                } else if (rtp != null && config != null) {
                    for ((offset, size) in AacUnits.split(buffer, rtp.offset, rtp.length, sizeLength, indexLength)) {
                        listener.onAudio(config, rate, channels, buffer, offset, size)
                    }
                }
            } else {
                readResponse(first)
            }
            val now = System.currentTimeMillis()
            if (now - lastKeepAlive > keepAliveMs) {
                lastKeepAlive = now
                send("GET_PARAMETER", Sdp.resolve(base, sdp.control), emptyList())
            }
        }
    }

    private fun request(method: String, target: String, headers: List<Pair<String, String>> = emptyList()): Response {
        send(method, target, headers)
        var response = readResponse(read())
        if (response.status == 401) {
            val header = response.header("www-authenticate") ?: throw RtspException("Camera refused the login", refused = true)
            val digestAt = header.indexOf("Digest", ignoreCase = true)
            challenge = Messages.challenge(if (digestAt >= 0) header.substring(digestAt) else header)
            send(method, target, headers)
            response = readResponse(read())
            if (response.status == 401) throw RtspException("Wrong user name or password", refused = true)
        }
        if (response.status != 200) throw RtspException("$method failed: ${response.status} ${response.reason}".trim())
        return response
    }

    private fun send(method: String, target: String, headers: List<Pair<String, String>>) {
        val all = ArrayList(headers)
        session?.let { all += "Session" to it }
        challenge?.let { current ->
            all += "Authorization" to if (current["scheme"] == "basic") {
                Messages.basic(user, password)
            } else {
                nonceCount += 1
                Messages.digest(current, method, target, user, password, nonceCount, "%016x".format(System.nanoTime()))
            }
        }
        cseq += 1
        val bytes = Messages.request(method, target, cseq, all)
        val out = socket?.getOutputStream() ?: throw RtspException("Closed")
        out.write(bytes)
        out.flush()
    }

    private fun readResponse(first: Int): Response {
        val lines = ArrayList<String>()
        val line = StringBuilder()
        var c = first
        while (true) {
            if (c == '\n'.code) {
                val text = line.toString().trimEnd('\r')
                line.setLength(0)
                if (text.isEmpty()) {
                    if (lines.isNotEmpty()) break
                } else {
                    lines += text
                }
            } else {
                line.append(c.toChar())
                if (line.length > MAX_LINE) throw RtspException("Malformed reply")
            }
            c = read()
        }
        val length = lines.firstOrNull { it.startsWith("Content-Length:", ignoreCase = true) }
            ?.substringAfter(':')?.trim()?.toIntOrNull() ?: 0
        val body = ByteArray(length.coerceIn(0, MAX_BODY))
        readFully(body, body.size)
        return Messages.parseHead(lines, String(body, Charsets.UTF_8)) ?: throw RtspException("Malformed reply")
    }

    private fun read(): Int {
        val value = try {
            input.read()
        } catch (_: SocketTimeoutException) {
            throw RtspException("No data for ${(socket?.soTimeout ?: 0) / 1000} s")
        }
        if (value < 0) throw RtspException("Camera closed the stream")
        return value
    }

    private fun readFully(buffer: ByteArray, length: Int) {
        var total = 0
        while (total < length) {
            val count = try {
                input.read(buffer, total, length - total)
            } catch (_: SocketTimeoutException) {
                throw RtspException("No data for ${(socket?.soTimeout ?: 0) / 1000} s")
            }
            if (count < 0) throw RtspException("Camera closed the stream")
            total += count
        }
    }

    private companion object {
        const val CONNECT_TIMEOUT_MS = 5000
        const val REPLY_TIMEOUT_MS = 8000
        const val SILENCE_MS = 10000
        const val MAX_LINE = 4096
        const val MAX_BODY = 64 * 1024
    }
}
