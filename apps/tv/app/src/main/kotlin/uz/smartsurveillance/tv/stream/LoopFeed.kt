package uz.smartsurveillance.tv.stream

import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Surface
import java.io.IOException
import uz.smartsurveillance.tv.BuildConfig
import uz.smartsurveillance.tv.rtsp.RtspException
import uz.smartsurveillance.tv.v380.AnnexB
import uz.smartsurveillance.tv.v380.Codec
import uz.smartsurveillance.tv.v380.Sps
import uz.smartsurveillance.tv.v380.V380Exception
import uz.smartsurveillance.tv.v380.VideoSize

interface Source {
    fun run()
    fun close()
}

abstract class LoopFeed(spec: Spec, key: String) : Feed(spec, key) {
    @Volatile
    protected var running = false

    @Volatile
    private var source: Source? = null

    @Volatile
    private var done: (() -> Unit)? = null

    @Volatile
    private var muted = false

    private var thread: Thread? = null
    private val main = Handler(Looper.getMainLooper())
    private val skip = HashSet<String>()
    protected val sound = AudioPipe()

    protected abstract fun connect(attempt: Attempt): Source

    protected open fun stopping() {}

    protected open fun unreachable() {}

    override fun start(surface: Surface) {
        if (running) return
        running = true
        thread = Thread({
            try {
                loop(surface)
            } finally {
                sound.release()
                main.post { done?.invoke() }
            }
        }, "feed-${camera.id}").apply { start() }
    }

    override fun stop(done: () -> Unit) {
        val current = thread
        if (current == null) {
            done()
            return
        }
        this.done = done
        running = false
        stopping()
        source?.close()
        current.interrupt()
    }

    override fun mute(muted: Boolean) {
        this.muted = muted
        sound.mute(muted)
    }

    private fun loop(surface: Surface) {
        val retry = Retry()
        var reduced = false
        var announced = false
        while (running) {
            val attempt = Attempt(surface, high = spec.quality == Quality.High && !reduced)
            val current = connect(attempt)
            source = current
            if (!running) current.close()
            var unreachable = false
            var refused: String? = null
            try {
                current.run()
            } catch (error: V380Exception) {
                unreachable = error.unreachable
                if (error.refused) refused = error.message
                if (running) stats.error = error.message
            } catch (error: RtspException) {
                unreachable = error.unreachable
                if (error.refused) refused = error.message
                if (running) stats.error = error.message
            } catch (error: IOException) {
                if (running) stats.error = error.message ?: error.javaClass.simpleName
            } catch (error: Exception) {
                if (running) stats.error = "${error.javaClass.simpleName} ${error.message ?: ""}".trim()
            } finally {
                source = null
                current.close()
                attempt.release()
            }
            log("session ended: ${stats.error}")
            if (!running) break
            if (attempt.tooLarge && !reduced) {
                reduced = true
                continue
            }
            if (attempt.played) retry.success()
            if (attempt.decoderLimit) {
                stateFlow.value = FeedState.DecoderLimit
                if (!pause(DECODER_RETRY_MS)) break
                skip.clear()
                continue
            }
            val delay = retry.failure()
            if (unreachable && !announced) {
                announced = true
                unreachable()
            }
            val offline = retry.offline(unreachable)
            if (!countdown(delay) { seconds -> if (refused != null) FeedState.Failed(refused, seconds) else FeedState.Waiting(seconds, offline) }) break
            if (!offline && refused == null) stateFlow.value = FeedState.Connecting
        }
    }

    private fun countdown(delayMs: Long, state: (Int) -> FeedState): Boolean {
        var left = delayMs
        while (left > 0) {
            if (!running) return false
            stateFlow.value = state(((left + 999) / 1000).toInt())
            val step = minOf(left, 1000L)
            if (!pause(step)) return false
            left -= step
        }
        return running
    }

    private fun pause(ms: Long): Boolean = try {
        Thread.sleep(ms)
        running
    } catch (_: InterruptedException) {
        false
    }

    inner class Attempt(private val surface: Surface, val high: Boolean) : VideoDecoder.Listener {
        @Volatile var played = false
        @Volatile var decoderLimit = false
        @Volatile var tooLarge = false
        private var decoder: VideoDecoder? = null
        private var codec: Codec? = null
        private var parameters: List<ByteArray>? = null
        private var fallback: VideoSize? = null
        private var lowLatency: Pair<ByteArray, ByteArray?>? = null
        private var latencyAt = 0L
        private val startedAt = System.currentTimeMillis()

        fun session(description: String, size: VideoSize? = null) {
            fallback = size
            stats.stream = description
            log("session $description")
        }

        fun bytes(count: Int) {
            stats.bytes.addAndGet(count.toLong())
        }

        fun video(input: ByteArray, key: Boolean) {
            if (decoderLimit || tooLarge || !running) return
            val data = if (key) reorderFree(input) else input
            var current = decoder
            if (current == null) {
                if (!key) return
                val type = AnnexB.codecOf(data) ?: return
                val sets = AnnexB.parameterSets(data, type) ?: return
                val size = (if (type == Codec.Hevc) Sps.hevcSize(sets[1].bytes) else Sps.avcSize(sets[0].bytes))
                    ?: fallback ?: return
                if (high && !Codecs.hardwareFits(type.mime, size.width, size.height)) {
                    tooLarge = true
                    stats.error = "${size.width}x${size.height} is larger than the decoder allows, using the smaller stream"
                    source?.close()
                    return
                }
                try {
                    current = VideoDecoder.create(type, sets.map { AnnexB.withStartCode(it.bytes) }, size, surface, skip, this)
                } catch (error: DecoderLimitException) {
                    decoderLimit = true
                    stats.error = error.message
                    log("decoder limit: ${error.message}")
                    source?.close()
                    return
                }
                decoder = current
                codec = type
                parameters = sets.map { it.bytes }
                stats.decoder = current.name
                sizeFlow.value = size
            } else if (key) {
                val type = codec ?: return
                val sets = AnnexB.parameterSets(data, type)
                if (sets != null && !same(sets.map { it.bytes })) {
                    log("parameter sets changed, restarting decoder")
                    current.release()
                    decoder = null
                    video(data, key)
                    return
                }
            }
            current.queue(data, key)
        }

        fun audio(push: (AudioPipe) -> Unit) {
            if (!spec.audio || !running) return
            sound.mute(muted)
            push(sound)
            val description = sound.description
            stats.audio = description
            if (!audioFlow.value && description != null && !description.startsWith("Unknown") && !description.startsWith("Audio failed")) {
                audioFlow.value = true
            }
        }

        private fun reorderFree(data: ByteArray): ByteArray {
            if (AnnexB.codecOf(data) != Codec.Hevc) return data
            val nals = AnnexB.nals(data, Codec.Hevc)
            val sps = nals.firstOrNull { it.type == 33 } ?: return data
            val known = lowLatency
            val patched = if (known != null && known.first.contentEquals(sps.bytes)) {
                known.second
            } else {
                Sps.hevcLowLatency(sps.bytes).also {
                    lowLatency = sps.bytes to it
                    if (it != null) log("stream declares frame reordering, decoding without it")
                }
            } ?: return data
            val out = java.io.ByteArrayOutputStream(data.size + 8)
            for (nal in nals) {
                out.write(START)
                out.write(if (nal.type == 33) patched else nal.bytes)
            }
            return out.toByteArray()
        }

        private fun same(sets: List<ByteArray>): Boolean {
            val known = parameters ?: return false
            return known.size == sets.size && known.indices.all { known[it].contentEquals(sets[it]) }
        }

        override fun onRendered(latencyUs: Long) {
            stats.frames.incrementAndGet()
            if (!played) {
                played = true
                stats.error = null
                stats.startup = "first picture ${System.currentTimeMillis() - startedAt} ms after connecting"
                log(stats.startup ?: "")
                stateFlow.value = FeedState.Playing
            }
            val now = System.currentTimeMillis()
            if (now - latencyAt > 1000) {
                latencyAt = now
                stats.latency = "decode ${latencyUs / 1000} ms"
            }
        }

        override fun onFailed(message: String) {
            stats.error = message
            decoder?.name?.let { synchronized(skip) { skip += it } }
            source?.close()
        }

        fun release() {
            decoder?.release()
            decoder = null
        }
    }

    protected fun log(message: String) {
        if (BuildConfig.DEBUG) Log.d("Feed", "${camera.id} ${spec.quality}: $message")
    }

    private companion object {
        const val DECODER_RETRY_MS = 30_000L
        val START = byteArrayOf(0, 0, 0, 1)
    }
}
