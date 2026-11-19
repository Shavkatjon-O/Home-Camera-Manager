package uz.home.cameras.tv.stream

import uz.home.cameras.tv.rtsp.RtspClient
import uz.home.cameras.tv.rtsp.RtspListener
import uz.home.cameras.tv.v380.Codec

class RtspFeed(spec: Spec, key: String) : LoopFeed(spec, key) {
    override fun connect(attempt: Attempt): Source {
        val main = attempt.high || camera.subPath.isBlank()
        val client = RtspClient(
            camera.host,
            camera.port,
            if (main) camera.mainPath else camera.subPath,
            camera.user,
            camera.password,
            audio = spec.audio,
            listener = object : RtspListener {
                override fun onSession(description: String) = attempt.session("${if (main) "main" else "sub"} stream, $description")

                override fun onBytes(count: Int) = attempt.bytes(count)

                override fun onVideo(codec: Codec, data: ByteArray, key: Boolean) = attempt.video(data, key)

                override fun onAudio(config: ByteArray, sampleRate: Int, channels: Int, data: ByteArray, offset: Int, length: Int) =
                    attempt.audio { it.aac(config, sampleRate, channels, data, offset, length) }
            },
        )
        return object : Source {
            override fun run() = client.run()

            override fun close() = client.close()
        }
    }
}
