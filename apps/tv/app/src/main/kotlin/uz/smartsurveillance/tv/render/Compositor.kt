package uz.smartsurveillance.tv.render

import android.graphics.SurfaceTexture
import android.opengl.EGL14
import android.opengl.EGLContext
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.view.Surface
import java.util.concurrent.atomic.AtomicInteger
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class Compositor(private val view: GLSurfaceView) : GLSurfaceView.Renderer {
    private class Stream(val key: String, val texture: Int, val surfaceTexture: SurfaceTexture, val surface: Surface, val context: EGLContext) {
        val pending = AtomicInteger()
        val matrix = FloatArray(16)
        var ready = false
    }

    private class Request(val key: String, val onSurface: (Surface) -> Unit)

    private val main = Handler(Looper.getMainLooper())
    private val frames = HandlerThread("frames").apply { start() }
    private val frameHandler = Handler(frames.looper)
    private val streams = HashMap<String, Stream>()
    private val waiting = ArrayList<Request>()
    private var program: Program? = null
    private var width = 0
    private var height = 0

    @Volatile
    private var scene = Scene()

    var onContextLost: (() -> Unit)? = null

    fun open(key: String, onSurface: (Surface) -> Unit) {
        view.queueEvent {
            val request = Request(key, onSurface)
            if (program != null && EGL14.eglGetCurrentContext() != EGL14.EGL_NO_CONTEXT) create(request) else waiting += request
        }
    }

    fun close(key: String) {
        view.queueEvent {
            waiting.removeAll { it.key == key }
            streams.remove(key)?.let { release(it, true) }
        }
    }

    fun show(next: Scene) {
        scene = next
        view.requestRender()
    }

    fun shutdown() {
        frames.quitSafely()
    }

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        program = Program()
        if (streams.isNotEmpty()) {
            streams.values.forEach { release(it, false) }
            streams.clear()
            main.post { onContextLost?.invoke() }
        }
        val queued = waiting.toList()
        waiting.clear()
        queued.forEach { create(it) }
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        this.width = width
        this.height = height
        GLES20.glViewport(0, 0, width, height)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        val current = program ?: return
        for (stream in streams.values) {
            val count = stream.pending.getAndSet(0)
            if (count <= 0) continue
            try {
                repeat(count) { stream.surfaceTexture.updateTexImage() }
                stream.surfaceTexture.getTransformMatrix(stream.matrix)
                stream.ready = true
            } catch (_: RuntimeException) {
            }
        }
        if (width == 0 || height == 0) return
        val w = width.toFloat()
        val h = height.toFloat()
        for (tile in scene.tiles) {
            val stream = streams[tile.key ?: continue] ?: continue
            if (!stream.ready) continue
            val rect = Geometry.fit(tile.cell.scale(w, h), tile.aspect)
            current.draw(stream.texture, stream.matrix, Geometry.quad(rect, w, h, tile.lens, tile.lenses))
        }
    }

    private fun create(request: Request) {
        streams.remove(request.key)?.let { release(it, true) }
        val texture = Program.newTexture()
        val surfaceTexture = SurfaceTexture(texture)
        val surface = Surface(surfaceTexture)
        val stream = Stream(request.key, texture, surfaceTexture, surface, EGL14.eglGetCurrentContext())
        surfaceTexture.setOnFrameAvailableListener({
            stream.pending.incrementAndGet()
            view.requestRender()
        }, frameHandler)
        streams[request.key] = stream
        main.post { request.onSurface(surface) }
    }

    private fun release(stream: Stream, deleteTexture: Boolean) {
        stream.surfaceTexture.setOnFrameAvailableListener(null)
        runCatching { stream.surface.release() }
        runCatching { stream.surfaceTexture.release() }
        if (deleteTexture && stream.context == EGL14.eglGetCurrentContext()) Program.deleteTexture(stream.texture)
    }
}
