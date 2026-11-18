package uz.home.cameras.tv.player

import android.content.Context
import android.os.SystemClock
import android.util.Log
import androidx.annotation.OptIn
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.VideoSize
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.rtsp.RtspMediaSource
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import uz.home.cameras.tv.BuildConfig

interface LiveListener {
    fun onFirstFrame()
    fun onFailure(reason: String)
}

@OptIn(UnstableApi::class)
class LivePlayer(context: Context) {
    private val loadControl = DefaultLoadControl.Builder()
        .setBufferDurationsMs(MIN_BUFFER_MS, MAX_BUFFER_MS, BUFFER_FOR_PLAYBACK_MS, BUFFER_AFTER_REBUFFER_MS)
        .setPrioritizeTimeOverSizeThresholds(true)
        .build()

    private val sources = RtspMediaSource.Factory()
        .setForceUseRtpTcp(true)
        .setTimeoutMs(RTSP_TIMEOUT_MS)

    val player: ExoPlayer = ExoPlayer.Builder(context)
        .setRenderersFactory(DefaultRenderersFactory(context).setEnableDecoderFallback(true))
        .setLoadControl(loadControl)
        .build()

    private val playingState = MutableStateFlow(false)
    val playing: StateFlow<Boolean> = playingState.asStateFlow()

    private val aspectState = MutableStateFlow(16f / 9f)
    val aspect: StateFlow<Float> = aspectState.asStateFlow()

    var listener: LiveListener? = null

    private var url: String? = null
    private var startedAt = 0L
    private var catchingUp = false
    private var checks = 0
    private var firstFrame = false
    private var stalledSince = 0L

    init {
        player.videoScalingMode = C.VIDEO_SCALING_MODE_SCALE_TO_FIT
        player.playWhenReady = true
        player.addListener(object : Player.Listener {
            override fun onRenderedFirstFrame() {
                firstFrame = true
                log("first frame after ${SystemClock.elapsedRealtime() - startedAt} ms")
                listener?.onFirstFrame()
            }

            override fun onPlayerError(error: PlaybackException) {
                log("error ${error.errorCodeName}")
                listener?.onFailure(error.errorCodeName)
            }

            override fun onPlaybackStateChanged(playbackState: Int) {
                if (playbackState == Player.STATE_BUFFERING) log("buffering at offset ${player.totalBufferedDuration} ms")
                if (playbackState == Player.STATE_ENDED) {
                    log("stream ended")
                    listener?.onFailure("ended")
                }
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                playingState.value = isPlaying
            }

            override fun onVideoSizeChanged(videoSize: VideoSize) {
                val ratio = videoSize.width * videoSize.pixelWidthHeightRatio / videoSize.height
                if (ratio > 0f && ratio.isFinite()) aspectState.value = ratio
            }
        })
    }

    fun play(next: String) {
        url = next
        startedAt = SystemClock.elapsedRealtime()
        firstFrame = false
        stalledSince = 0L
        normalSpeed()
        player.setMediaSource(sources.createMediaSource(MediaItem.fromUri(next)))
        player.prepare()
        player.playWhenReady = true
    }

    fun stop() {
        url = null
        firstFrame = false
        stalledSince = 0L
        normalSpeed()
        player.stop()
        player.clearMediaItems()
    }

    fun check() {
        val current = url ?: return
        if (firstFrame && player.playbackState == Player.STATE_BUFFERING) {
            val now = SystemClock.elapsedRealtime()
            if (stalledSince == 0L) stalledSince = now
            if (now - stalledSince > STALL_MS) {
                log("stalled for ${now - stalledSince} ms")
                stalledSince = 0L
                listener?.onFailure("stalled")
            }
            return
        }
        stalledSince = 0L
        if (!player.isPlaying) return
        val lag = player.totalBufferedDuration
        checks += 1
        if (checks % LOG_EVERY_CHECKS == 0) log("offset $lag ms speed ${player.playbackParameters.speed}")
        when (driftAction(lag, catchingUp)) {
            DriftAction.Rebuild -> {
                log("rebuild at offset $lag ms")
                play(current)
            }
            DriftAction.CatchUp -> {
                log("catch up from offset $lag ms")
                catchingUp = true
                player.setPlaybackSpeed(CATCH_UP_SPEED)
            }
            DriftAction.Normal -> {
                log("caught up at offset $lag ms")
                normalSpeed()
            }
            DriftAction.Keep -> Unit
        }
    }

    fun release() {
        listener = null
        player.release()
    }

    private fun normalSpeed() {
        catchingUp = false
        if (player.playbackParameters.speed != 1f) player.setPlaybackSpeed(1f)
    }

    private fun log(message: String) {
        if (BuildConfig.DEBUG) Log.d(TAG, message)
    }

    private companion object {
        const val TAG = "LivePlayer"
        const val MIN_BUFFER_MS = 500
        const val MAX_BUFFER_MS = 2000
        const val BUFFER_FOR_PLAYBACK_MS = 100
        const val BUFFER_AFTER_REBUFFER_MS = 300
        const val RTSP_TIMEOUT_MS = 10_000L
        const val LOG_EVERY_CHECKS = 4
        const val STALL_MS = 4000L
    }
}
