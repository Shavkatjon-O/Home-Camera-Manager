package uz.smartsurveillance.tv.wall

import uz.smartsurveillance.tv.camera.Camera

data class WallItem(val camera: Camera, val lens: Int) {
    val lensLabel: String? get() = if (camera.lenses > 1) "Lens ${lens + 1}" else null
}

data class WallPlan(val cols: Int, val rows: Int, val slots: List<WallItem?>) {
    val occupied: List<Int> get() = slots.indices.filter { slots[it] != null }

    fun col(index: Int): Int = index / rows

    fun row(index: Int): Int = index % rows

    companion object {
        fun items(cameras: List<Camera>): List<WallItem> = cameras.flatMap { camera ->
            if (camera.lenses > 1) (0 until camera.lenses).map { WallItem(camera, it) } else listOf(WallItem(camera, 0))
        }

        fun grid(count: Int): Pair<Int, Int> = when {
            count <= 1 -> 1 to 1
            count == 2 -> 2 to 1
            count <= 4 -> 2 to 2
            count <= 6 -> 3 to 2
            count <= 9 -> 3 to 3
            else -> 4 to (count + 3) / 4
        }

        fun arrange(items: List<WallItem>, line: Int): List<WallItem?> {
            val slots = ArrayList<WallItem?>()
            for (item in items) {
                val span = if (item.lens == 0) item.camera.lenses else 1
                val used = slots.size % line
                if (span > 1 && span <= line && used + span > line) {
                    while (slots.size % line != 0) slots.add(null)
                }
                slots.add(item)
            }
            return slots
        }

        fun of(cameras: List<Camera>): WallPlan {
            val items = items(cameras.filter { it.enabled })
            var count = items.size
            var plan = WallPlan(1, 1, emptyList())
            repeat(3) {
                val (cols, rows) = grid(count)
                val slots = arrange(items, rows)
                plan = WallPlan(cols, rows, slots)
                if (slots.size <= cols * rows) return plan
                count = slots.size
            }
            return plan
        }
    }
}
