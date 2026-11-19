package uz.home.cameras.tv.wall

import org.junit.Assert.assertEquals
import org.junit.Test
import uz.home.cameras.tv.camera.Camera
import uz.home.cameras.tv.camera.Kind

class WallPlanTest {
    private fun rtsp(id: String) = Camera(id, id, Kind.Rtsp, "h", 554, "u", "p")
    private fun ptz(id: String) = Camera(id, id, Kind.V380, "h", 8800, "u", "p", deviceId = 1, lenses = 2)

    private fun names(plan: WallPlan) = plan.slots.map { slot -> slot?.let { "${it.camera.id}${it.lens}" } }

    @Test
    fun fourCamerasFillThreeColumnsByColumn() {
        val plan = WallPlan.of(listOf(rtsp("a"), rtsp("b"), ptz("p"), ptz("q")))
        assertEquals(3, plan.cols)
        assertEquals(2, plan.rows)
        assertEquals(listOf("a0", "b0", "p0", "p1", "q0", "q1"), names(plan))
        assertEquals(1, plan.col(2))
        assertEquals(0, plan.row(2))
        assertEquals(1, plan.row(3))
    }

    @Test
    fun keepsLensesInOneColumn() {
        val plan = WallPlan.of(listOf(rtsp("a").copy(enabled = false), rtsp("b"), ptz("p"), ptz("q")))
        assertEquals(listOf("b0", null, "p0", "p1", "q0", "q1"), names(plan))
        assertEquals(listOf(0, 2, 3, 4, 5), plan.occupied)
    }

    @Test
    fun smallWalls() {
        assertEquals(listOf("p0", "p1"), names(WallPlan.of(listOf(ptz("p")))))
        assertEquals(2 to 1, WallPlan.grid(2))
        val one = WallPlan.of(listOf(rtsp("a")))
        assertEquals(1, one.cols)
        assertEquals(listOf("a0"), names(one))
        assertEquals(emptyList<String?>(), names(WallPlan.of(emptyList())))
    }
}
