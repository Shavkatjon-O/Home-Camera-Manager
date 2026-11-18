package uz.home.cameras.tv.player

import org.junit.Assert.assertEquals
import org.junit.Test

class PolicyTest {
    @Test
    fun backoffSteps() {
        val backoff = Backoff()
        assertEquals(listOf(1000L, 2000L, 5000L, 10000L, 10000L), List(5) { backoff.next() })
        backoff.reset()
        assertEquals(1000L, backoff.next())
    }

    @Test
    fun driftActions() {
        assertEquals(DriftAction.Keep, driftAction(lagMs = 400, catchingUp = false))
        assertEquals(DriftAction.CatchUp, driftAction(lagMs = 600, catchingUp = false))
        assertEquals(DriftAction.Keep, driftAction(lagMs = 300, catchingUp = true))
        assertEquals(DriftAction.Normal, driftAction(lagMs = 150, catchingUp = true))
        assertEquals(DriftAction.Rebuild, driftAction(lagMs = 3500, catchingUp = true))
        assertEquals(DriftAction.Rebuild, driftAction(lagMs = 3500, catchingUp = false))
    }
}
