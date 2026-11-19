package uz.home.cameras.tv.stream

import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import uz.home.cameras.tv.v380.Client
import uz.home.cameras.tv.v380.ClientListener
import uz.home.cameras.tv.v380.MediaFrame
import uz.home.cameras.tv.v380.Ptz
import uz.home.cameras.tv.v380.PtzMove
import uz.home.cameras.tv.v380.Session
import uz.home.cameras.tv.v380.VideoSize

class V380Feed(spec: Spec, key: String, private val onUnreachable: (V380Feed) -> Unit) : LoopFeed(spec, key) {
    @Volatile
    private var client: Client? = null

    @Volatile
    private var moving = false

    private val commands = Executors.newSingleThreadExecutor()

    override val ptz: Boolean get() = true

    override fun connect(attempt: Attempt): Source {
        val next = Client(
            camera.host,
            camera.port,
            camera.deviceId,
            camera.user,
            camera.password,
            hd = attempt.high,
            audio = spec.audio,
            listener = object : ClientListener {
                override fun onSession(session: Session) {
                    val quality = if (attempt.high) "HD" else "SD"
                    val crypto = if (session.encrypted) ", encrypted" else ""
                    attempt.session(
                        "$quality ${session.width}x${session.height}, protocol ${session.version}/${session.communication}$crypto",
                        VideoSize(session.width.toInt(), session.height.toInt()),
                    )
                }

                override fun onBytes(count: Int) = attempt.bytes(count)

                override fun onVideo(frame: MediaFrame) = attempt.video(frame.payload, frame.key)

                override fun onAudio(frame: MediaFrame) = attempt.audio { it.push(frame.type, frame.payload) }
            },
        )
        client = next
        return object : Source {
            override fun run() = next.run()

            override fun close() {
                if (client === next) client = null
                next.close()
            }
        }
    }

    override fun stopping() {
        val session = client
        if (moving && session != null) runCatching { commands.execute { session.send(Ptz.packet(PtzMove.Stop)) } }
        commands.shutdown()
        runCatching { commands.awaitTermination(COMMAND_WAIT_MS, TimeUnit.MILLISECONDS) }
    }

    override fun unreachable() = onUnreachable(this)

    override fun move(move: PtzMove) {
        val session = client ?: return
        moving = move != PtzMove.Stop
        runCatching { commands.execute { log("ptz $move sent ${session.send(Ptz.packet(move))}") } }
    }

    private companion object {
        const val COMMAND_WAIT_MS = 500L
    }
}
