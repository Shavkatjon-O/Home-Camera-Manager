package uz.home.cameras.tv.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ConfigTest {
    private val full = """
        {
          "wall": {"url": "rtsp://tv:secret@192.168.1.219:8554/tv_wall", "cols": 3, "rows": 2, "fps": 15},
          "tiles": [
            {"index": 2, "label": "Yard, lens 1", "camera_uuid": "b2", "camera_name": "Yard", "lens": 0, "ptz": true, "url": "rtsp://h/tv_tile_2"},
            {"index": 0, "label": "Gate", "camera_uuid": "a1", "camera_name": "Gate", "lens": null, "ptz": false, "url": "rtsp://h/tv_tile_0"},
            {"index": 3, "label": "Yard, lens 2", "camera_uuid": "b2", "camera_name": "Yard", "lens": 1, "ptz": true, "url": "rtsp://h/tv_tile_3", "extra": [1, 2]}
          ]
        }
    """.trimIndent()

    @Test
    fun parsesWallAndTiles() {
        val config = parseConfig(full)
        assertEquals("rtsp://tv:secret@192.168.1.219:8554/tv_wall", config.wall.url)
        assertEquals(3, config.wall.cols)
        assertEquals(2, config.wall.rows)
        assertEquals(listOf(0, 2, 3), config.tiles.map { it.index })
        val yard = config.tiles[1]
        assertEquals("b2", yard.cameraUuid)
        assertEquals("Yard", yard.title)
        assertEquals("Lens 1", yard.lensLabel)
        assertTrue(yard.ptz)
        val gate = config.tiles[0]
        assertNull(gate.lens)
        assertNull(gate.lensLabel)
        assertFalse(gate.ptz)
    }

    @Test
    fun appliesDefaultsAndClampsGrid() {
        val config = parseConfig(
            """{"wall": {"url": "rtsp://h/tv_wall", "cols": 0, "rows": -1}, "tiles": [{"index": 0, "url": "rtsp://h/t0", "label": "Only"}]}""",
        )
        assertEquals(1, config.wall.cols)
        assertEquals(1, config.wall.rows)
        val tile = config.tiles.single()
        assertEquals("Only", tile.title)
        assertFalse(tile.ptz)
        assertEquals("", tile.cameraUuid)
    }

    @Test
    fun dropsTilesWithoutUrlAndDuplicates() {
        val config = parseConfig(
            """{"wall": {"url": "w", "cols": 2, "rows": 1}, "tiles": [
                {"index": 0, "url": "a"}, {"index": 0, "url": "b"}, {"index": 1, "url": ""}, {"index": -1, "url": "c"}
            ]}""",
        )
        assertEquals(listOf("a"), config.tiles.map { it.url })
    }

    @Test
    fun missingTilesGiveEmptyList() {
        val config = parseConfig("""{"wall": {"url": "w", "cols": 1, "rows": 1}}""")
        assertTrue(config.tiles.isEmpty())
    }

    @Test
    fun parsesPairingReplies() {
        val created = parsePairingCreated("""{"id": 42, "code": "048213", "expires_at": "2026-11-19T10:00:00Z"}""")
        assertEquals("42", created.id)
        assertEquals("048213", created.code)
        val pending = parsePairingStatus("""{"status": "pending"}""")
        assertEquals("pending", pending.status)
        assertNull(pending.token)
        val approved = parsePairingStatus("""{"status": "approved", "token": "abc"}""")
        assertEquals("abc", approved.token)
    }

    @Test
    fun encodesPtzMoveWithAllAxes() {
        assertEquals("""{"pan":0.0,"tilt":0.5,"zoom":0.0}""", json.encodeToString(PtzMove(tilt = 0.5f)))
        assertEquals("""{"device_name":"Bravia"}""", json.encodeToString(PairingRequest("Bravia")))
    }

    @Test
    fun normalizesServerAddress() {
        assertEquals("http://192.168.1.219:8750", normalizeServer(" 192.168.1.219:8750/ "))
        assertEquals("https://cams.local", normalizeServer("https://cams.local//"))
        assertEquals("", normalizeServer("   "))
    }
}
