package uz.home.cameras.tv.stream

import android.view.Surface
import java.util.concurrent.atomic.AtomicLong
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import uz.home.cameras.tv.camera.Camera
import uz.home.cameras.tv.v380.PtzMove
import uz.home.cameras.tv.v380.VideoSize

enum class Quality { Low, High }

sealed interface FeedState {
    data object Connecting : FeedState
    data object Playing : FeedState
    data class Waiting(val seconds: Int, val offline: Boolean) : FeedState
    data object DecoderLimit : FeedState
    data class Failed(val reason: String, val seconds: Int) : FeedState
}

fun FeedState.label(): String? = when (this) {
    FeedState.Playing -> null
    FeedState.Connecting -> "Connecting"
    is FeedState.Waiting -> if (offline) "Offline" else "Reconnecting in $seconds s"
    FeedState.DecoderLimit -> "Decoder limit"
    is FeedState.Failed -> reason
}

data class Rates(val fps: Double, val kbps: Double)

const val RATE_WINDOW_S = 4.0

class FeedStats {
    val bytes = AtomicLong()
    val frames = AtomicLong()

    @Volatile var decoder: String? = null
    @Volatile var error: String? = null
    @Volatile var audio: String? = null
    @Volatile var stream: String? = null
    @Volatile var latency: String? = null
    @Volatile var startup: String? = null

    private var lastBytes = 0L
    private var lastFrames = 0L
    private var lastAt = 0L
    private var rates = Rates(0.0, 0.0)

    @Synchronized
    fun sample(now: Long): Rates {
        if (lastAt == 0L) {
            lastAt = now
            lastBytes = bytes.get()
            lastFrames = frames.get()
            return rates
        }
        val elapsed = (now - lastAt) / 1000.0
        if (elapsed >= RATE_WINDOW_S) {
            val b = bytes.get()
            val f = frames.get()
            rates = Rates((f - lastFrames) / elapsed, (b - lastBytes) * 8 / elapsed / 1000)
            lastAt = now
            lastBytes = b
            lastFrames = f
        }
        return rates
    }
}

data class Spec(val camera: Camera, val quality: Quality, val audio: Boolean)

abstract class Feed(val spec: Spec, val key: String) {
    val camera: Camera get() = spec.camera

    protected val stateFlow = MutableStateFlow<FeedState>(FeedState.Connecting)
    val state: StateFlow<FeedState> = stateFlow.asStateFlow()

    protected val sizeFlow = MutableStateFlow<VideoSize?>(null)
    val size: StateFlow<VideoSize?> = sizeFlow.asStateFlow()

    protected val audioFlow = MutableStateFlow(false)
    val hasAudio: StateFlow<Boolean> = audioFlow.asStateFlow()

    val stats = FeedStats()

    open val ptz: Boolean get() = false

    abstract fun start(surface: Surface)

    abstract fun stop(done: () -> Unit)

    open fun mute(muted: Boolean) {}

    open fun move(move: PtzMove) {}
}

class Retry(private val backoff: Backoff = Backoff()) {
    var failures = 0
        private set

    fun success() {
        failures = 0
        backoff.reset()
    }

    fun failure(): Long {
        failures += 1
        return backoff.next()
    }

    fun offline(unreachable: Boolean): Boolean = unreachable || failures >= OFFLINE_AFTER

    private companion object {
        const val OFFLINE_AFTER = 3
    }
}
