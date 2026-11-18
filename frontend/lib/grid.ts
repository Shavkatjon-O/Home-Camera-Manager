export type WallLayout = "auto" | "1" | "2x2" | "3x3"

export const WALL_LAYOUTS: { value: WallLayout; label: string }[] = [
  { value: "auto", label: "Auto" },
  { value: "1", label: "1" },
  { value: "2x2", label: "2x2" },
  { value: "3x3", label: "3x3" },
]

export interface WallGrid {
  cols: number
  rows: number
  perPage: number
}

export function autoGrid(count: number): { cols: number; rows: number } {
  if (count <= 1) return { cols: 1, rows: 1 }
  if (count === 2) return { cols: 2, rows: 1 }
  if (count <= 4) return { cols: 2, rows: 2 }
  if (count <= 6) return { cols: 3, rows: 2 }
  if (count <= 9) return { cols: 3, rows: 3 }
  return { cols: 4, rows: Math.ceil(count / 4) }
}

export function wallGrid(layout: WallLayout, count: number, portrait: boolean): WallGrid {
  if (layout === "1") return { cols: 1, rows: 1, perPage: 1 }
  if (layout === "2x2") return { cols: 2, rows: 2, perPage: 4 }
  if (layout === "3x3") return { cols: 3, rows: 3, perPage: 9 }
  const grid = autoGrid(count)
  const swap = portrait && grid.cols > grid.rows
  return {
    cols: swap ? grid.rows : grid.cols,
    rows: swap ? grid.cols : grid.rows,
    perPage: Math.max(count, 1),
  }
}

export function isWallLayout(value: unknown): value is WallLayout {
  return value === "auto" || value === "1" || value === "2x2" || value === "3x3"
}
