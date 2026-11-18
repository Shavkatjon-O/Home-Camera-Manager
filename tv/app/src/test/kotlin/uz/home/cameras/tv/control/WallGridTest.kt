package uz.home.cameras.tv.control

import org.junit.Assert.assertEquals
import org.junit.Test

class WallGridTest {
    private val full = WallGrid(cols = 3, rows = 2, occupied = (0..5).toList())

    @Test
    fun indexesAreColumnMajor() {
        assertEquals(0, full.col(1))
        assertEquals(1, full.row(1))
        assertEquals(1, full.col(2))
        assertEquals(0, full.row(2))
    }

    @Test
    fun movesBetweenNeighbours() {
        assertEquals(1, full.move(0, Key.Down))
        assertEquals(0, full.move(1, Key.Up))
        assertEquals(2, full.move(0, Key.Right))
        assertEquals(5, full.move(3, Key.Right))
        assertEquals(1, full.move(3, Key.Left))
    }

    @Test
    fun staysAtEdges() {
        assertEquals(0, full.move(0, Key.Up))
        assertEquals(0, full.move(0, Key.Left))
        assertEquals(5, full.move(5, Key.Down))
        assertEquals(5, full.move(5, Key.Right))
    }

    @Test
    fun skipsEmptySlots() {
        val grid = WallGrid(cols = 3, rows = 2, occupied = listOf(0, 1, 2, 3, 4))
        assertEquals(4, grid.move(3, Key.Right))
        assertEquals(4, grid.move(4, Key.Down))
        val sparse = WallGrid(cols = 3, rows = 2, occupied = listOf(1, 4))
        assertEquals(4, sparse.move(1, Key.Right))
        assertEquals(1, sparse.move(4, Key.Left))
    }

    @Test
    fun recoversFromUnknownFocus() {
        assertEquals(0, full.move(9, Key.Right))
        assertEquals(0, full.first)
        val empty = WallGrid(cols = 2, rows = 2, occupied = emptyList())
        assertEquals(-1, empty.first ?: -1)
    }
}
