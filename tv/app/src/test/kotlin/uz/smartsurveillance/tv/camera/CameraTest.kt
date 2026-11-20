package uz.smartsurveillance.tv.camera

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class CameraTest {
    private val text = """
        cameras=a,ptz1,broken
        a.name=Camera A
        a.kind=rtsp
        a.host=192.168.1.104
        a.user=admin
        a.password=p@ss:w/rd
        a.main=/Streaming/Channels/101
        a.sub=/Streaming/Channels/102
        ptz1.name=PTZ 1
        ptz1.kind=v380
        ptz1.host=192.168.1.237
        ptz1.device=12345678
        ptz1.password=x
        ptz1.lenses=2
        broken.kind=onvif
    """.trimIndent()

    @Test
    fun parsesCompiledDefaults() {
        val cameras = Camera.parse(text)
        assertEquals(listOf("a", "ptz1"), cameras.map { it.id })
        val a = cameras[0]
        assertEquals(Kind.Rtsp, a.kind)
        assertEquals(554, a.port)
        assertEquals("rtsp://admin:p%40ss%3Aw%2Frd@192.168.1.104:554/Streaming/Channels/102", a.url(main = false))
        assertEquals("rtsp://admin:p%40ss%3Aw%2Frd@192.168.1.104:554/Streaming/Channels/101", a.url(main = true))
        val ptz = cameras[1]
        assertEquals(Kind.V380, ptz.kind)
        assertEquals(8800, ptz.port)
        assertEquals(12345678L, ptz.deviceId)
        assertEquals(2, ptz.lenses)
        assertEquals("192.168.1.237", ptz.address)
    }

    @Test
    fun parsesAddresses() {
        assertEquals("192.168.1.9" to 8800, Camera.parseAddress(" 192.168.1.9 ", 8800))
        assertEquals("cam.local" to 8554, Camera.parseAddress("cam.local:8554", 554))
        assertNull(Camera.parseAddress("", 554))
        assertNull(Camera.parseAddress("1.2.3.4:99999", 554))
        assertNull(Camera.parseAddress("rtsp://1.2.3.4", 554))
        val camera = Camera.parse(text)[0]
        assertEquals("10.0.0.5:9000", camera.withAddress("10.0.0.5:9000")!!.address)
        assertEquals("10.0.0.5", camera.withAddress("10.0.0.5")!!.address)
    }
}
