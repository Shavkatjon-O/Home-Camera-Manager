import type { Camera } from "@/lib/types"

export type WallLayout = "auto" | "1" | "2x2" | "3x3"

export interface WallItem {
  key: string
  camera: Camera
  lens: number | null
}

export function wallItems(cameras: Camera[]): WallItem[] {
  return cameras.flatMap((camera): WallItem[] =>
    camera.lenses > 1
      ? Array.from({ length: camera.lenses }, (_, lens) => ({ key: `${camera.uuid}-${lens}`, camera, lens }))
      : [{ key: camera.uuid, camera, lens: null }],
  )
}

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

export type WallSlot = WallItem | null

export type WallFlow = "row" | "column"

export interface WallPlan extends WallGrid {
  flow: WallFlow
  slots: WallSlot[]
}

export function arrangeItems(items: WallItem[], line: number): WallSlot[] {
  const slots: WallSlot[] = []
  for (const item of items) {
    const span = item.lens === 0 ? item.camera.lenses : 1
    const used = slots.length % line
    if (span > 1 && span <= line && used + span > line) {
      while (slots.length % line !== 0) slots.push(null)
    }
    slots.push(item)
  }
  return slots
}

export function wallPlan(layout: WallLayout, items: WallItem[], portrait: boolean): WallPlan {
  let count = items.length
  let plan: WallPlan | null = null
  for (let pass = 0; pass < 3; pass += 1) {
    const grid = wallGrid(layout, count, portrait)
    const flow: WallFlow = grid.cols >= grid.rows ? "column" : "row"
    const slots = arrangeItems(items, flow === "column" ? grid.rows : grid.cols)
    const capacity = grid.cols * grid.rows
    plan = { ...grid, perPage: layout === "auto" ? Math.max(capacity, 1) : grid.perPage, flow, slots }
    if (layout !== "auto" || slots.length <= capacity) break
    count = slots.length
  }
  return plan as WallPlan
}

export function isWallLayout(value: unknown): value is WallLayout {
  return value === "auto" || value === "1" || value === "2x2" || value === "3x3"
}
