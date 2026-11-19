package uz.home.cameras.tv.wall

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.wifi.WifiManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import uz.home.cameras.tv.camera.Camera
import uz.home.cameras.tv.camera.Kind
import uz.home.cameras.tv.camera.Store
import uz.home.cameras.tv.render.Box
import uz.home.cameras.tv.render.Compositor
import uz.home.cameras.tv.render.Geometry
import uz.home.cameras.tv.render.Scene
import uz.home.cameras.tv.render.SceneTile
import uz.home.cameras.tv.stream.Feed
import uz.home.cameras.tv.stream.FeedState
import uz.home.cameras.tv.stream.Quality
import uz.home.cameras.tv.stream.RtspFeed
import uz.home.cameras.tv.stream.Spec
import uz.home.cameras.tv.stream.V380Feed
import uz.home.cameras.tv.v380.Discovery
import uz.home.cameras.tv.v380.PtzMove

class Wall(private val context: Context, private val store: Store, private val compositor: Compositor) {
    private val scope = MainScope()
    private val connectivity = context.getSystemService(ConnectivityManager::class.java)

    private val camerasFlow = MutableStateFlow(store.cameras())
    val cameras: StateFlow<List<Camera>> = camerasFlow.asStateFlow()

    private val planFlow = MutableStateFlow(WallPlan.of(camerasFlow.value))
    val plan: StateFlow<WallPlan> = planFlow.asStateFlow()

    private val fullFlow = MutableStateFlow<Int?>(null)
    val full: StateFlow<Int?> = fullFlow.asStateFlow()

    private val feedsFlow = MutableStateFlow<Map<String, Feed>>(emptyMap())
    val feeds: StateFlow<Map<String, Feed>> = feedsFlow.asStateFlow()

    private val sceneFlow = MutableStateFlow(Scene())
    val scene: StateFlow<Scene> = sceneFlow.asStateFlow()

    private val mutedFlow = MutableStateFlow(false)
    val muted: StateFlow<Boolean> = mutedFlow.asStateFlow()

    private val discoveryFlow = MutableStateFlow<String?>(null)
    val discovery: StateFlow<String?> = discoveryFlow.asStateFlow()

    private val eventsFlow = MutableStateFlow<List<String>>(emptyList())
    val events: StateFlow<List<String>> = eventsFlow.asStateFlow()

    private var started = false
    private var serial = 0
    private var stopping = 0
    private var autoDiscovered = false
    private var searching = false
    private var networkLost = false
    private var moving: PtzMove? = null
    private val watchers = HashMap<String, Job>()

    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onLost(network: Network) {
            scope.launch { networkLost = true }
        }

        override fun onAvailable(network: Network) {
            scope.launch {
                if (started && networkLost) {
                    networkLost = false
                    log("network back, reconnecting")
                    reload()
                }
            }
        }
    }

    init {
        compositor.onContextLost = { reload() }
    }

    fun start() {
        if (started) return
        started = true
        runCatching { connectivity?.registerDefaultNetworkCallback(networkCallback) }
        sync()
    }

    fun stop() {
        if (!started) return
        stopMove()
        started = false
        runCatching { connectivity?.unregisterNetworkCallback(networkCallback) }
        sync()
    }

    fun release() {
        stop()
        compositor.shutdown()
        scope.cancel()
    }

    fun reload() {
        if (!started) return
        started = false
        sync()
        started = true
        sync()
    }

    fun open(slot: Int) {
        if (planFlow.value.slots.getOrNull(slot) == null) return
        stopMove()
        fullFlow.value = slot
        sync()
    }

    fun back() {
        stopMove()
        fullFlow.value = null
        sync()
    }

    fun step(delta: Int) {
        val current = fullFlow.value ?: return
        val occupied = planFlow.value.occupied
        if (occupied.isEmpty()) return
        val position = occupied.indexOf(current).coerceAtLeast(0)
        val next = occupied[(position + delta + occupied.size) % occupied.size]
        if (next != current) open(next)
    }

    fun fullItem(): WallItem? = fullFlow.value?.let { planFlow.value.slots.getOrNull(it) }

    fun fullFeed(): Feed? = fullItem()?.let { feedsFlow.value[it.camera.id] }

    fun move(move: PtzMove) {
        val feed = fullFeed() ?: return
        if (!feed.ptz) return
        moving = move
        feed.move(move)
    }

    fun stopMove() {
        if (moving == null) return
        moving = null
        fullFeed()?.move(PtzMove.Stop)
    }

    fun toggleMute() = setMuted(!mutedFlow.value)

    fun setMuted(value: Boolean) {
        mutedFlow.value = value
        feedsFlow.value.values.forEach { it.mute(value) }
    }

    fun applyCameras() {
        camerasFlow.value = store.cameras()
        val next = WallPlan.of(camerasFlow.value)
        val full = fullFlow.value
        if (full != null) {
            val before = planFlow.value.slots.getOrNull(full)
            val after = next.slots.getOrNull(full)
            if (before == null || after == null || before.camera.id != after.camera.id || !after.camera.enabled) fullFlow.value = null
        }
        planFlow.value = next
        sync()
    }

    fun discover(auto: Boolean) {
        if (searching) return
        searching = true
        discoveryFlow.value = "Searching for V380 cameras"
        scope.launch {
            val found = withContext(Dispatchers.IO) { multicast { runCatching { Discovery.search() } } }
            searching = false
            val list = found.getOrElse {
                discoveryFlow.value = "Search failed: ${it.message ?: it.javaClass.simpleName}"
                log("discovery failed: ${it.message}")
                return@launch
            }
            val v380 = camerasFlow.value.filter { it.kind == Kind.V380 }
            val lines = ArrayList<String>()
            var changed = false
            for (camera in v380) {
                val hit = list.firstOrNull { it.id == camera.deviceId.toString() }
                when {
                    hit == null -> lines += "${camera.name} not found"
                    hit.ip == camera.host -> lines += "${camera.name} at ${hit.ip}"
                    else -> {
                        lines += "${camera.name} moved to ${hit.ip}"
                        store.setAddress(camera.id, hit.ip, camera.port)
                        changed = true
                    }
                }
            }
            val others = list.count { found -> v380.none { it.deviceId.toString() == found.id } }
            if (others > 0) lines += "$others other device${if (others == 1) "" else "s"}"
            discoveryFlow.value = if (list.isEmpty()) "No V380 camera answered" else lines.joinToString(", ")
            log("${if (auto) "auto " else ""}discovery: ${discoveryFlow.value}")
            if (changed) applyCameras()
        }
    }

    private inline fun <T> multicast(block: () -> T): T {
        val wifi = context.applicationContext.getSystemService(WifiManager::class.java)
        val lock = runCatching { wifi?.createMulticastLock("v380-discovery")?.apply { setReferenceCounted(false); acquire() } }.getOrNull()
        try {
            return block()
        } finally {
            runCatching { lock?.release() }
        }
    }

    private fun desired(): Map<String, Spec> {
        val plan = planFlow.value
        val item = fullFlow.value?.let { plan.slots.getOrNull(it) }
        if (item != null) return mapOf(item.camera.id to Spec(item.camera, Quality.High, audio = true))
        return plan.slots.filterNotNull().map { it.camera }.distinctBy { it.id }
            .associate { it.id to Spec(it, Quality.Low, audio = false) }
    }

    private fun sync() {
        val want = if (started) desired() else emptyMap()
        val current = feedsFlow.value.toMutableMap()
        for ((id, feed) in feedsFlow.value) {
            if (want[id] != feed.spec) {
                current.remove(id)
                stopFeed(feed)
            }
        }
        if (stopping == 0) {
            for ((id, spec) in want) if (id !in current) current[id] = startFeed(spec)
        }
        feedsFlow.value = current
        rebuild()
    }

    private fun stopFeed(feed: Feed) {
        watchers.remove(feed.key)?.cancel()
        stopping += 1
        feed.stop {
            stopping -= 1
            compositor.close(feed.key)
            if (stopping == 0) sync()
        }
    }

    private fun startFeed(spec: Spec): Feed {
        serial += 1
        val key = "${spec.camera.id}-$serial"
        val feed = when (spec.camera.kind) {
            Kind.Rtsp -> RtspFeed(spec, key)
            Kind.V380 -> V380Feed(spec, key) { scope.launch { unreachable(it) } }
        }
        feed.mute(mutedFlow.value)
        compositor.open(key) { surface ->
            if (feedsFlow.value[spec.camera.id] === feed) feed.start(surface) else compositor.close(key)
        }
        watchers[key] = scope.launch {
            launch { feed.size.collect { rebuild() } }
            launch {
                feed.state.collect { state ->
                    if (state == FeedState.DecoderLimit) log("${spec.camera.name} ${spec.quality}: decoder limit, ${feed.stats.error ?: ""}".trim())
                }
            }
        }
        return feed
    }

    private fun unreachable(feed: V380Feed) {
        if (autoDiscovered || feedsFlow.value[feed.camera.id] !== feed) return
        autoDiscovered = true
        log("${feed.camera.name} did not answer at ${feed.camera.address}, searching")
        discover(auto = true)
    }

    private fun rebuild() {
        val plan = planFlow.value
        val feeds = feedsFlow.value
        val full = fullFlow.value
        val tiles = if (full != null) {
            val item = plan.slots.getOrNull(full)
            if (item == null) emptyList() else listOf(tile(full, item, feeds[item.camera.id], Box(0f, 0f, 1f, 1f)))
        } else {
            plan.slots.mapIndexedNotNull { index, item ->
                item ?: return@mapIndexedNotNull null
                val cell = Box(
                    plan.col(index).toFloat() / plan.cols,
                    plan.row(index).toFloat() / plan.rows,
                    1f / plan.cols,
                    1f / plan.rows,
                )
                tile(index, item, feeds[item.camera.id], cell)
            }
        }
        val scene = Scene(tiles)
        sceneFlow.value = scene
        compositor.show(scene)
    }

    private fun tile(slot: Int, item: WallItem, feed: Feed?, cell: Box): SceneTile {
        val size = feed?.size?.value
        val aspect = if (size == null) Geometry.DEFAULT_ASPECT else Geometry.lensAspect(size.width, size.height, item.camera.lenses)
        return SceneTile(slot, item.camera.id, feed?.key, item.lens, item.camera.lenses, cell, aspect)
    }

    private fun log(message: String) {
        val time = SimpleDateFormat("HH:mm:ss", Locale.US).format(Date())
        eventsFlow.value = (eventsFlow.value + "$time $message").takeLast(MAX_EVENTS)
    }

    private companion object {
        const val MAX_EVENTS = 30
    }
}
