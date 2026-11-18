package uz.home.cameras.tv.player

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.os.Build
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import uz.home.cameras.tv.data.Api
import uz.home.cameras.tv.data.ApiException
import uz.home.cameras.tv.data.PtzMove
import uz.home.cameras.tv.data.Settings
import uz.home.cameras.tv.data.TvConfig

sealed interface Target {
    data object Wall : Target
    data class Tile(val index: Int) : Target
}

class Viewer(
    context: Context,
    private val settings: Settings,
    private val live: LivePlayer,
    private val scope: CoroutineScope,
    private val onUnauthorized: () -> Unit,
) {
    private val connectivity = context.getSystemService(ConnectivityManager::class.java)

    private val configState = MutableStateFlow<TvConfig?>(null)
    val config: StateFlow<TvConfig?> = configState.asStateFlow()

    private val targetState = MutableStateFlow<Target>(Target.Wall)
    val target: StateFlow<Target> = targetState.asStateFlow()

    private val statusState = MutableStateFlow<String?>(null)
    val status: StateFlow<String?> = statusState.asStateFlow()

    private val backoff = Backoff()
    private val ptzQueue = Channel<suspend () -> Unit>(Channel.UNLIMITED)
    private var connectJob: Job? = null
    private var watchJob: Job? = null
    private var active = false
    private var networkLost = false

    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onLost(network: Network) {
            scope.launch {
                if (!active) return@launch
                networkLost = true
                live.stop()
                retry("Network lost, retrying")
            }
        }

        override fun onAvailable(network: Network) {
            scope.launch {
                if (!active || !networkLost) return@launch
                networkLost = false
                backoff.reset()
                connect()
            }
        }
    }

    init {
        live.listener = object : LiveListener {
            override fun onFirstFrame() {
                backoff.reset()
                statusState.value = null
            }

            override fun onFailure(reason: String) {
                if (!active) return
                live.stop()
                retry("Reconnecting")
            }
        }
        scope.launch {
            for (task in ptzQueue) task()
        }
    }

    fun start() {
        if (active) return
        active = true
        networkLost = false
        backoff.reset()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            runCatching { connectivity?.registerDefaultNetworkCallback(networkCallback) }
        }
        connect()
        watchJob = scope.launch {
            while (true) {
                delay(CHECK_MS)
                live.check()
            }
        }
    }

    fun stop() {
        if (!active) return
        active = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            runCatching { connectivity?.unregisterNetworkCallback(networkCallback) }
        }
        connectJob?.cancel()
        watchJob?.cancel()
        live.stop()
        statusState.value = null
    }

    fun reload() {
        backoff.reset()
        live.stop()
        connect()
    }

    fun show(next: Target) {
        targetState.value = next
        val url = urlFor(configState.value, next)
        if (url == null) {
            connect()
            return
        }
        connectJob?.cancel()
        statusState.value = CONNECTING
        live.play(url)
    }

    fun ptz(cameraUuid: String, move: PtzMove?) {
        val token = settings.token ?: return
        val api = Api(settings.server)
        ptzQueue.trySend {
            try {
                if (move == null) api.ptzStop(token, cameraUuid) else api.ptzMove(token, cameraUuid, move)
            } catch (error: CancellationException) {
                throw error
            } catch (error: ApiException) {
                if (error.code == 401) unauthorized()
            } catch (_: Exception) {
            }
        }
    }

    private fun connect(waitMs: Long = 0, reason: String = "") {
        connectJob?.cancel()
        connectJob = scope.launch {
            var left = waitMs
            while (left > 0) {
                statusState.value = "$reason in ${(left + 999) / 1000} s"
                val step = minOf(left, 1000L)
                delay(step)
                left -= step
            }
            statusState.value = CONNECTING
            val token = settings.token
            if (token == null) {
                unauthorized()
                return@launch
            }
            val fresh = try {
                Api(settings.server).config(token)
            } catch (error: CancellationException) {
                throw error
            } catch (error: ApiException) {
                if (error.code == 401) {
                    unauthorized()
                } else {
                    retry("Server error ${error.code}, retrying")
                }
                return@launch
            } catch (_: Exception) {
                retry("Server not reachable, retrying")
                return@launch
            }
            configState.value = fresh
            val current = targetState.value
            if (current is Target.Tile && fresh.tiles.none { it.index == current.index }) {
                targetState.value = Target.Wall
            }
            val url = urlFor(fresh, targetState.value)
            if (url == null) {
                retry("No cameras, retrying")
                return@launch
            }
            live.play(url)
        }
    }

    private fun retry(reason: String) {
        if (!active) return
        connect(backoff.next(), reason)
    }

    private fun unauthorized() {
        if (!active) return
        settings.token = null
        stop()
        onUnauthorized()
    }

    private fun urlFor(config: TvConfig?, target: Target): String? = when (target) {
        Target.Wall -> config?.wall?.url?.takeIf { it.isNotBlank() }
        is Target.Tile -> config?.tiles?.firstOrNull { it.index == target.index }?.url
    }

    private companion object {
        const val CONNECTING = "Connecting"
        const val CHECK_MS = 250L
    }
}
