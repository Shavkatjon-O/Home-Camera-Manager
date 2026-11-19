package uz.home.cameras.tv.stream

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.media.MediaCodec
import android.media.MediaFormat
import java.nio.ByteBuffer
import java.nio.ByteOrder
import uz.home.cameras.tv.v380.Adts
import uz.home.cameras.tv.v380.Alaw
import uz.home.cameras.tv.v380.ImaAdpcm

class Sound(val sampleRate: Int, channels: Int) {
    private val track: AudioTrack

    init {
        val mask = if (channels == 2) AudioFormat.CHANNEL_OUT_STEREO else AudioFormat.CHANNEL_OUT_MONO
        val minimum = AudioTrack.getMinBufferSize(sampleRate, mask, AudioFormat.ENCODING_PCM_16BIT).coerceAtLeast(1024)
        val target = sampleRate * channels * 2 * BUFFER_MS / 1000
        track = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                    .build(),
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setSampleRate(sampleRate)
                    .setChannelMask(mask)
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .build(),
            )
            .setBufferSizeInBytes(maxOf(minimum, target))
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()
        track.play()
    }

    fun write(samples: ShortArray, count: Int = samples.size) {
        if (count <= 0) return
        runCatching { track.write(samples, 0, count, AudioTrack.WRITE_NON_BLOCKING) }
    }

    fun mute(muted: Boolean) {
        runCatching { track.setVolume(if (muted) 0f else 1f) }
    }

    fun release() {
        runCatching { track.pause() }
        runCatching { track.flush() }
        runCatching { track.release() }
    }

    private companion object {
        const val BUFFER_MS = 160
    }
}

class AacDecoder(val sampleRate: Int, channelCount: Int, config: ByteArray) {
    private val codec: MediaCodec = MediaCodec.createDecoderByType(MediaFormat.MIMETYPE_AUDIO_AAC)
    private val info = MediaCodec.BufferInfo()
    private var presentation = 0L
    val channels = channelCount.coerceIn(1, 2)

    init {
        val format = MediaFormat.createAudioFormat(MediaFormat.MIMETYPE_AUDIO_AAC, sampleRate, channels)
        format.setByteBuffer("csd-0", ByteBuffer.wrap(config))
        codec.configure(format, null, null, 0)
        codec.start()
    }

    fun decode(frame: ByteArray, offset: Int, length: Int, sink: (ShortArray, Int) -> Unit) {
        val input = codec.dequeueInputBuffer(INPUT_WAIT_US)
        if (input >= 0) {
            val buffer = codec.getInputBuffer(input)
            if (buffer != null && length <= buffer.capacity()) {
                buffer.clear()
                buffer.put(frame, offset, length)
                codec.queueInputBuffer(input, 0, length, presentation, 0)
                presentation += 1024L * 1_000_000 / sampleRate
            } else {
                codec.queueInputBuffer(input, 0, 0, presentation, 0)
            }
        }
        while (true) {
            val output = codec.dequeueOutputBuffer(info, 0)
            if (output < 0) break
            val buffer = codec.getOutputBuffer(output)
            if (buffer != null && info.size > 0) {
                buffer.position(info.offset)
                buffer.limit(info.offset + info.size)
                val shorts = buffer.order(ByteOrder.nativeOrder()).asShortBuffer()
                val samples = ShortArray(shorts.remaining())
                shorts.get(samples)
                sink(samples, samples.size)
            }
            codec.releaseOutputBuffer(output, false)
        }
    }

    fun release() {
        runCatching { codec.stop() }
        runCatching { codec.release() }
    }

    private companion object {
        const val INPUT_WAIT_US = 20_000L
    }
}

class AudioPipe {
    @Volatile
    private var sound: Sound? = null
    private var aac: AacDecoder? = null
    @Volatile
    private var muted = false
    private var failed = false

    @Volatile
    var description: String? = null
        private set

    fun mute(value: Boolean) {
        muted = value
        sound?.mute(value)
    }

    fun push(type: Int, payload: ByteArray) {
        if (failed) return
        try {
            when (type) {
                0x16 -> play(8000, 1, "IMA ADPCM 8 kHz mono") { sink -> ImaAdpcm.decodeBlock(payload, 0, payload.size).let { sink(it, it.size) } }
                0x1A -> play(8000, 1, "G.711 A-law 8 kHz mono") { sink -> Alaw.decode(payload, 0, payload.size).let { sink(it, it.size) } }
                0x18 -> {
                    val header = Adts.parse(payload) ?: return
                    val size = minOf(header.frameSize, payload.size) - header.headerSize
                    if (size <= 0) return
                    aac(header.config(), header.sampleRate, header.channels, payload, header.headerSize, size)
                }
                else -> description = "Unknown audio type 0x%02x".format(type)
            }
        } catch (error: Exception) {
            failed = true
            description = "Audio failed: ${error.javaClass.simpleName}"
            release()
        }
    }

    fun aac(config: ByteArray, rate: Int, channels: Int, data: ByteArray, offset: Int, length: Int) {
        if (failed) return
        try {
            val decoder = aac ?: AacDecoder(rate, channels, config).also { aac = it }
            play(decoder.sampleRate, decoder.channels, "AAC ${decoder.sampleRate / 1000} kHz ${if (decoder.channels == 1) "mono" else "stereo"}") { sink ->
                decoder.decode(data, offset, length, sink)
            }
        } catch (error: Exception) {
            failed = true
            description = "Audio failed: ${error.javaClass.simpleName}"
            release()
        }
    }

    private inline fun play(rate: Int, channels: Int, label: String, decode: ((ShortArray, Int) -> Unit) -> Unit) {
        val out = sound ?: Sound(rate, channels).also {
            it.mute(muted)
            sound = it
            description = label
        }
        decode { samples, count -> out.write(samples, count) }
    }

    fun release() {
        sound?.release()
        sound = null
        aac?.release()
        aac = null
    }
}
