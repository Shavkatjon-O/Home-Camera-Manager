package uz.home.cameras.tv.stream

class Backoff(private val stepsMs: List<Long> = listOf(1000L, 2000L, 5000L, 10000L, 30000L)) {
    private var attempt = 0

    fun next(): Long {
        val value = stepsMs[attempt.coerceAtMost(stepsMs.lastIndex)]
        attempt += 1
        return value
    }

    fun reset() {
        attempt = 0
    }
}
