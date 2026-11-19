package uz.home.cameras.tv.stream

import android.media.MediaCodec
import android.media.MediaFormat
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.view.Surface
import java.nio.ByteBuffer
import java.util.ArrayDeque
import uz.home.cameras.tv.v380.Codec
import uz.home.cameras.tv.v380.VideoSize

class DecoderLimitException(message: String) : Exception(message)

class VideoDecoder private constructor(
    val name: String,
    private val codec: MediaCodec,
    private val thread: HandlerThread,
    private val handler: Handler,
    private val callbacks: Callbacks,
) {
    interface Listener {
        fun onRendered(latencyUs: Long)
        fun onFailed(message: String)
    }

    private class Access(val data: ByteArray, val key: Boolean, val receivedUs: Long)

    private class Callbacks(var listener: Listener) : MediaCodec.Callback() {
        lateinit var owner: VideoDecoder

        override fun onInputBufferAvailable(codec: MediaCodec, index: Int) {
            owner.free.add(index)
            owner.pump()
        }

        override fun onOutputBufferAvailable(codec: MediaCodec, index: Int, info: MediaCodec.BufferInfo) {
            if (owner.released) return
            runCatching { codec.releaseOutputBuffer(index, true) }
            if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG == 0) {
                listener.onRendered(System.nanoTime() / 1000 - info.presentationTimeUs)
            }
        }

        override fun onError(codec: MediaCodec, error: MediaCodec.CodecException) {
            if (!owner.released) listener.onFailed("Decoder error ${error.diagnosticInfo}")
        }

        override fun onOutputFormatChanged(codec: MediaCodec, format: MediaFormat) = Unit
    }

    private val lock = Any()
    private val pending = ArrayDeque<Access>()
    private val free = ArrayDeque<Int>()
    private var waitingKey = false

    @Volatile
    private var released = false

    fun queue(data: ByteArray, key: Boolean) {
        synchronized(lock) {
            if (pending.size >= MAX_PENDING) {
                pending.clear()
                waitingKey = true
            }
            if (waitingKey && !key) return
            waitingKey = false
            pending.add(Access(data, key, System.nanoTime() / 1000))
        }
        handler.post { pump() }
    }

    private fun pump() {
        if (released) return
        while (free.isNotEmpty()) {
            val next = synchronized(lock) { pending.pollFirst() } ?: return
            val index = free.pollFirst() ?: return
            try {
                val buffer: ByteBuffer = codec.getInputBuffer(index) ?: continue
                buffer.clear()
                if (next.data.size > buffer.capacity()) {
                    codec.queueInputBuffer(index, 0, 0, next.receivedUs, 0)
                    continue
                }
                buffer.put(next.data)
                val flags = if (next.key) MediaCodec.BUFFER_FLAG_KEY_FRAME else 0
                codec.queueInputBuffer(index, 0, next.data.size, next.receivedUs, flags)
            } catch (error: IllegalStateException) {
                if (!released) callbacks.listener.onFailed("Decoder stopped")
                return
            }
        }
    }

    fun release() {
        if (released) return
        released = true
        handler.post {
            runCatching { codec.stop() }
            runCatching { codec.release() }
        }
        thread.quitSafely()
        runCatching { thread.join(2000) }
    }

    companion object {
        private const val MAX_PENDING = 30

        fun create(
            codecType: Codec,
            parameterSets: List<ByteArray>,
            size: VideoSize,
            surface: Surface,
            skip: Set<String>,
            listener: Listener,
        ): VideoDecoder {
            val candidates = Codecs.candidates(codecType.mime, size.width, size.height).filter { it.name !in skip }
            if (candidates.isEmpty()) throw DecoderLimitException("No ${codecType.mime} decoder for ${size.width}x${size.height}")
            var last: Exception? = null
            for (candidate in candidates) {
                val thread = HandlerThread("decoder-${candidate.name}").apply { start() }
                val handler = Handler(thread.looper)
                var codec: MediaCodec? = null
                try {
                    codec = MediaCodec.createByCodecName(candidate.name)
                    val format = MediaFormat.createVideoFormat(codecType.mime, size.width, size.height)
                    if (codecType == Codec.Hevc) {
                        format.setByteBuffer("csd-0", ByteBuffer.wrap(parameterSets.fold(ByteArray(0)) { acc, nal -> acc + nal }))
                    } else {
                        parameterSets.forEachIndexed { index, nal -> format.setByteBuffer("csd-$index", ByteBuffer.wrap(nal)) }
                    }
                    format.setInteger(MediaFormat.KEY_PRIORITY, 0)
                    if (Build.VERSION.SDK_INT >= 30) format.setInteger(MediaFormat.KEY_LOW_LATENCY, 1)
                    val callbacks = Callbacks(listener)
                    codec.setCallback(callbacks, handler)
                    codec.configure(format, surface, null, 0)
                    val decoder = VideoDecoder(candidate.name, codec, thread, handler, callbacks)
                    callbacks.owner = decoder
                    codec.start()
                    return decoder
                } catch (error: Exception) {
                    last = error
                    runCatching { codec?.release() }
                    thread.quitSafely()
                }
            }
            throw DecoderLimitException("Decoder limit: ${last?.javaClass?.simpleName} ${last?.message ?: ""}".trim())
        }
    }
}
