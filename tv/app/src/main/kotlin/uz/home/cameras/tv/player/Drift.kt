package uz.home.cameras.tv.player

enum class DriftAction { Keep, CatchUp, Normal, Rebuild }

const val CATCH_UP_ABOVE_MS = 500L
const val CAUGHT_UP_BELOW_MS = 250L
const val REBUILD_ABOVE_MS = 3000L
const val CATCH_UP_SPEED = 1.5f

fun driftAction(lagMs: Long, catchingUp: Boolean): DriftAction = when {
    lagMs > REBUILD_ABOVE_MS -> DriftAction.Rebuild
    !catchingUp && lagMs > CATCH_UP_ABOVE_MS -> DriftAction.CatchUp
    catchingUp && lagMs < CAUGHT_UP_BELOW_MS -> DriftAction.Normal
    else -> DriftAction.Keep
}
