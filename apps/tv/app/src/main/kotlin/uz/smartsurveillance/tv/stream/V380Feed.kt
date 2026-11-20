package uz.smartsurveillance.tv.stream

import uz.smartsurveillance.tv.v380.Codec
import uz.smartsurveillance.tv.v380.PtzMove
import uz.smartsurveillance.tv.v380.SessionFacts
import uz.smartsurveillance.tv.v380.StreamKind
import uz.smartsurveillance.tv.v380.V380Client

/**
 * A feed that reaches a V380 camera directly over its LAN protocol.
 *
 * The high quality spec asks for the main stream and the low one for the sub stream. Sound is asked for only when
 * the spec wants audio, and PTZ records go over the same session as the video.
 *
 * @param onUnreachable Called when the camera did not accept a connection, so its address can be searched for.
 */
class V380Feed(spec: Spec, key: String, private val onUnreachable: (V380Feed) -> Unit) : LoopFeed(spec, key) {
    @Volatile
    private var client: V380Client? = null

    override val ptz: Boolean get() = camera.ptz

    override fun connect(attempt: Attempt): Source {
        val main = attempt.high
        val stream = if (main) StreamKind.Main else StreamKind.Sub
        val session = V380Client(
            V380Client.Config(
                host = camera.host,
                port = camera.port,
                deviceId = camera.deviceId,
                user = camera.user.ifEmpty { "admin" },
                password = camera.password,
                stream = stream,
                sound = spec.audio,
            ),
            object : V380Client.Listener {
                override fun onSession(facts: SessionFacts) = attempt.session(
                    "${if (main) "main" else "sub"} stream, device version ${facts.deviceVersion}, " +
                        "communication version ${facts.communicationVersion}",
                    facts.reportedSize,
                )

                override fun onBytes(count: Int) = attempt.bytes(count)

                override fun onVideo(codec: Codec, data: ByteArray, key: Boolean) = attempt.video(data, key)

                override fun onAudio(type: Int, payload: ByteArray) = attempt.audio { it.push(type, payload) }
            },
        )
        client = session
        return object : Source {
            override fun run() = session.run()

            override fun close() {
                session.close()
                if (client === session) client = null
            }
        }
    }

    override fun move(move: PtzMove) {
        client?.move(move)
    }

    override fun unreachable() = onUnreachable(this)
}
