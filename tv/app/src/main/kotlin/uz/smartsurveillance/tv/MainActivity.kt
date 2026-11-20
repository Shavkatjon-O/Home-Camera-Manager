package uz.smartsurveillance.tv

import android.media.AudioManager
import android.opengl.GLSurfaceView
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import uz.smartsurveillance.tv.camera.Store
import uz.smartsurveillance.tv.render.Compositor
import uz.smartsurveillance.tv.ui.App
import uz.smartsurveillance.tv.wall.Wall

class MainActivity : ComponentActivity() {
    private lateinit var video: GLSurfaceView
    private lateinit var wall: Wall

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        volumeControlStream = AudioManager.STREAM_MUSIC
        val store = Store(this)
        video = GLSurfaceView(this)
        video.setEGLContextClientVersion(2)
        val compositor = Compositor(video)
        video.setRenderer(compositor)
        video.renderMode = GLSurfaceView.RENDERMODE_WHEN_DIRTY
        video.isFocusable = false
        video.isFocusableInTouchMode = false
        wall = Wall(applicationContext, store, compositor)
        setContent { App(wall, store, video) }
    }

    override fun onStart() {
        super.onStart()
        video.onResume()
        wall.start()
    }

    override fun onStop() {
        wall.stop()
        video.onPause()
        super.onStop()
    }

    override fun onDestroy() {
        wall.release()
        super.onDestroy()
    }
}
