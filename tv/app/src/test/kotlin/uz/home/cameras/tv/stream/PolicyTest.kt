package uz.home.cameras.tv.stream

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class PolicyTest {
    @Test
    fun backoffStepsUpAndHolds() {
        val backoff = Backoff()
        assertEquals(listOf(1000L, 2000L, 5000L, 10000L, 30000L, 30000L), List(6) { backoff.next() })
        backoff.reset()
        assertEquals(1000L, backoff.next())
    }

    @Test
    fun retryTurnsOfflineAfterThreeFailuresOrWhenUnreachable() {
        val retry = Retry()
        retry.failure()
        assertFalse(retry.offline(unreachable = false))
        assertTrue(retry.offline(unreachable = true))
        retry.failure()
        retry.failure()
        assertTrue(retry.offline(unreachable = false))
        retry.success()
        assertEquals(1000L, retry.failure())
    }

    @Test
    fun statesHaveQuietLabels() {
        assertNull(FeedState.Playing.label())
        assertEquals("Connecting", FeedState.Connecting.label())
        assertEquals("Reconnecting in 5 s", FeedState.Waiting(5, offline = false).label())
        assertEquals("Offline", FeedState.Waiting(5, offline = true).label())
        assertEquals("Decoder limit", FeedState.DecoderLimit.label())
    }


    @Test
    fun ratesComeFromCounters() {
        val stats = FeedStats()
        stats.sample(1000)
        stats.bytes.addAndGet(500_000)
        stats.frames.addAndGet(60)
        assertEquals(0.0, stats.sample(3000).fps, 0.01)
        val rates = stats.sample(5000)
        assertEquals(15.0, rates.fps, 0.01)
        assertEquals(1000.0, rates.kbps, 0.01)
    }
}
