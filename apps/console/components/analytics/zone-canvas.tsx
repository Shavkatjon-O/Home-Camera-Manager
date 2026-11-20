"use client"

import * as React from "react"

import { clamp01, inSide, type DraftLine, type DraftZone, type RuleSelection, type Tool } from "@/lib/analytics"
import type { ViewPoint } from "@/lib/types"
import { cn } from "@/lib/utils"

interface Pixel {
  x: number
  y: number
}

type Gesture =
  | { kind: "tap"; start: Pixel }
  | { kind: "vertex"; key: string; index: number; start: Pixel; moved: boolean }
  | { kind: "end"; key: string; index: 0 | 1; start: Pixel; moved: boolean }
  | {
      kind: "move"
      target: "zone" | "line"
      key: string
      origin: ViewPoint
      points: ViewPoint[]
      start: Pixel
      moved: boolean
    }

const CLICK_SLOP_PX = 6
const DRAG_SLOP_PX = 3
const CLOSE_PX = 12
const SAME_POINT_PX = 6
const MIN_LINE_PX = 12
const HANDLE_PX = 6
const HIT_PX = 14
const MID_PX = 3.5
const ARROW_PX = 28
const ARROW_HEAD_PX = 8

const LABEL_FILL = "#ffffff"
const LABEL_HALO = "rgba(0, 0, 0, 0.8)"
const ZONE_STROKE = "#ffffff"

function distance(a: Pixel, b: Pixel): number {
  return Math.hypot(a.x - b.x, a.y - b.y)
}

function Label({
  x,
  y,
  anchor = "start",
  muted = false,
  children,
}: {
  x: number
  y: number
  anchor?: "start" | "middle" | "end"
  muted?: boolean
  children: React.ReactNode
}) {
  return (
    <text
      x={x}
      y={y}
      fontSize={11}
      textAnchor={anchor}
      dominantBaseline="middle"
      className="font-data"
      fill={LABEL_FILL}
      fillOpacity={muted ? 0.7 : 1}
      stroke={LABEL_HALO}
      strokeWidth={3}
      paintOrder="stroke"
      strokeLinejoin="round"
      pointerEvents="none"
    >
      {children}
    </text>
  )
}

function hintFor(tool: Tool, draft: ViewPoint[], empty: boolean): string | null {
  if (tool === "zone") {
    if (draft.length < 3) return "Click or tap the picture to add the corners of the zone."
    return "Click the first point, click the last point again or double click to close the zone."
  }
  if (tool === "line") {
    return draft.length === 0 ? "Click or tap where the line starts." : "Click or tap where the line ends."
  }
  if (empty) return "Draw a zone or a line on the picture."
  return null
}

export function ZoneCanvas({
  imageUrl,
  aspect,
  zones,
  lines,
  selection,
  vertex,
  tool,
  draft,
  onSelect,
  onDraft,
  onFinishZone,
  onFinishLine,
  onZoneShape,
  onLineShape,
}: {
  imageUrl: string
  aspect: number
  zones: DraftZone[]
  lines: DraftLine[]
  selection: RuleSelection
  vertex: number | null
  tool: Tool
  draft: ViewPoint[]
  onSelect: (selection: RuleSelection, vertex: number | null) => void
  onDraft: (points: ViewPoint[]) => void
  onFinishZone: (points: ViewPoint[]) => void
  onFinishLine: (points: [ViewPoint, ViewPoint]) => void
  onZoneShape: (key: string, polygon: ViewPoint[]) => void
  onLineShape: (key: string, points: [ViewPoint, ViewPoint]) => void
}) {
  const areaRef = React.useRef<HTMLDivElement>(null)
  const boxRef = React.useRef<HTMLDivElement>(null)
  const gesture = React.useRef<Gesture | null>(null)
  const pointer = React.useRef<number | null>(null)
  const [area, setArea] = React.useState({ width: 0, height: 0 })
  const [hover, setHover] = React.useState<ViewPoint | null>(null)

  React.useEffect(() => {
    const element = areaRef.current
    if (!element) return
    const observer = new ResizeObserver((entries) => {
      const box = entries[0].contentRect
      setArea({ width: box.width, height: box.height })
    })
    observer.observe(element)
    return () => observer.disconnect()
  }, [])

  const size = {
    width: Math.min(area.width, area.height * aspect),
    height: Math.min(area.height, area.width / aspect),
  }

  const px = (point: ViewPoint): Pixel => ({ x: point[0] * size.width, y: point[1] * size.height })

  const local = (event: { clientX: number; clientY: number }): Pixel => {
    const rect = boxRef.current?.getBoundingClientRect()
    if (!rect) return { x: 0, y: 0 }
    return { x: event.clientX - rect.left, y: event.clientY - rect.top }
  }

  const raw = (event: { clientX: number; clientY: number }): ViewPoint => {
    const rect = boxRef.current?.getBoundingClientRect()
    if (!rect || rect.width <= 0 || rect.height <= 0) return [0, 0]
    return [(event.clientX - rect.left) / rect.width, (event.clientY - rect.top) / rect.height]
  }

  const toView = (event: { clientX: number; clientY: number }): ViewPoint => {
    const point = raw(event)
    return [clamp01(point[0]), clamp01(point[1])]
  }

  const addZonePoint = (point: ViewPoint, here: Pixel) => {
    if (draft.length >= 3) {
      if (distance(here, px(draft[0])) <= CLOSE_PX) {
        onFinishZone(draft)
        return
      }
      if (distance(here, px(draft[draft.length - 1])) <= SAME_POINT_PX) {
        onFinishZone(draft)
        return
      }
    }
    if (draft.length > 0 && distance(here, px(draft[draft.length - 1])) <= SAME_POINT_PX) return
    onDraft([...draft, point])
  }

  const addLinePoint = (point: ViewPoint, here: Pixel) => {
    if (draft.length === 0) {
      onDraft([point])
      return
    }
    if (distance(here, px(draft[0])) < MIN_LINE_PX) return
    onFinishLine([draft[0], point])
  }

  const onPointerDown = (event: React.PointerEvent<HTMLDivElement>) => {
    const element = boxRef.current
    if (!element || event.button !== 0 || gesture.current) return
    try {
      element.setPointerCapture(event.pointerId)
    } catch {}
    pointer.current = event.pointerId
    const start = local(event)
    if (tool !== "select") {
      setHover(toView(event))
      gesture.current = { kind: "tap", start }
      return
    }
    const hit = event.target instanceof Element ? event.target.closest("[data-kind]") : null
    const kind = hit?.getAttribute("data-kind") ?? null
    const key = hit?.getAttribute("data-key") ?? ""
    const index = Number(hit?.getAttribute("data-index") ?? "0")
    if (kind === "vertex") {
      onSelect({ kind: "zone", key }, index)
      gesture.current = { kind: "vertex", key, index, start, moved: false }
      return
    }
    if (kind === "mid") {
      const zone = zones.find((item) => item.key === key)
      if (!zone) return
      const a = zone.polygon[index]
      const b = zone.polygon[(index + 1) % zone.polygon.length]
      const point: ViewPoint = [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2]
      onZoneShape(key, [...zone.polygon.slice(0, index + 1), point, ...zone.polygon.slice(index + 1)])
      onSelect({ kind: "zone", key }, index + 1)
      gesture.current = { kind: "vertex", key, index: index + 1, start, moved: true }
      return
    }
    if (kind === "end") {
      onSelect({ kind: "line", key }, null)
      gesture.current = { kind: "end", key, index: index === 1 ? 1 : 0, start, moved: false }
      return
    }
    if (kind === "zone") {
      const zone = zones.find((item) => item.key === key)
      if (!zone) return
      onSelect({ kind: "zone", key }, null)
      if (zone.whole_view) return
      gesture.current = { kind: "move", target: "zone", key, origin: raw(event), points: zone.polygon, start, moved: false }
      return
    }
    if (kind === "line") {
      const line = lines.find((item) => item.key === key)
      if (!line) return
      onSelect({ kind: "line", key }, null)
      gesture.current = { kind: "move", target: "line", key, origin: raw(event), points: line.points, start, moved: false }
      return
    }
    gesture.current = { kind: "tap", start }
  }

  const onPointerMove = (event: React.PointerEvent<HTMLDivElement>) => {
    if (tool !== "select") setHover(toView(event))
    const current = gesture.current
    if (!current || event.pointerId !== pointer.current || current.kind === "tap") return
    const here = local(event)
    if (!current.moved) {
      if (distance(here, current.start) < DRAG_SLOP_PX) return
      current.moved = true
    }
    if (current.kind === "vertex") {
      const zone = zones.find((item) => item.key === current.key)
      if (!zone) return
      const point = toView(event)
      onZoneShape(
        current.key,
        zone.polygon.map((item, index) => (index === current.index ? point : item)),
      )
      return
    }
    if (current.kind === "end") {
      const line = lines.find((item) => item.key === current.key)
      if (!line) return
      const point = toView(event)
      const other = line.points[current.index === 0 ? 1 : 0]
      if (distance(px(point), px(other)) < MIN_LINE_PX) return
      onLineShape(current.key, current.index === 0 ? [point, other] : [other, point])
      return
    }
    const now = raw(event)
    const xs = current.points.map((point) => point[0])
    const ys = current.points.map((point) => point[1])
    const dx = Math.min(1 - Math.max(...xs), Math.max(-Math.min(...xs), now[0] - current.origin[0]))
    const dy = Math.min(1 - Math.max(...ys), Math.max(-Math.min(...ys), now[1] - current.origin[1]))
    const moved = current.points.map((point): ViewPoint => [point[0] + dx, point[1] + dy])
    if (current.target === "zone") onZoneShape(current.key, moved)
    else onLineShape(current.key, [moved[0], moved[1]])
  }

  const onPointerUp = (event: React.PointerEvent<HTMLDivElement>) => {
    const current = gesture.current
    if (!current || event.pointerId !== pointer.current) return
    gesture.current = null
    pointer.current = null
    if (event.type === "pointercancel" || current.kind !== "tap") return
    const here = local(event)
    if (distance(here, current.start) > CLICK_SLOP_PX) return
    const point = toView(event)
    if (tool === "zone") addZonePoint(point, here)
    else if (tool === "line") addLinePoint(point, here)
    else onSelect(null, null)
  }

  const selectedZone = selection?.kind === "zone" ? zones.find((zone) => zone.key === selection.key) : undefined
  const selectedLine = selection?.kind === "line" ? lines.find((line) => line.key === selection.key) : undefined
  const ordered = [...zones.filter((zone) => zone.whole_view), ...zones.filter((zone) => !zone.whole_view)]
  const hint = hintFor(tool, draft, zones.length === 0 && lines.length === 0)
  const ready = size.width > 0 && size.height > 0

  return (
    <div className="relative min-h-0 flex-1 bg-black">
      <div ref={areaRef} className="absolute inset-0 flex items-center justify-center">
        <div
          ref={boxRef}
          role="application"
          aria-label="Zone and line editor"
          onPointerDown={onPointerDown}
          onPointerMove={onPointerMove}
          onPointerUp={onPointerUp}
          onPointerCancel={onPointerUp}
          onLostPointerCapture={(event) => {
            if (event.pointerId !== pointer.current) return
            gesture.current = null
            pointer.current = null
          }}
          onPointerLeave={() => setHover(null)}
          onContextMenu={(event) => event.preventDefault()}
          className={cn("relative touch-none select-none", tool !== "select" && "cursor-crosshair")}
          style={{ width: size.width, height: size.height }}
        >
          <svg className="absolute inset-0 size-full overflow-visible">
            {ready ? (
              <>
                <image
                  href={imageUrl}
                  x={0}
                  y={0}
                  width={size.width}
                  height={size.height}
                  preserveAspectRatio="none"
                  pointerEvents="none"
                />
                {ordered.map((zone) => {
                  const selected = selectedZone?.key === zone.key
                  const color = zone.suspended ? "var(--status-warn)" : selected ? "var(--focus)" : ZONE_STROKE
                  const points = zone.polygon.map(px)
                  const center = points.reduce(
                    (sum, point) => ({ x: sum.x + point.x / points.length, y: sum.y + point.y / points.length }),
                    { x: 0, y: 0 },
                  )
                  return (
                    <g
                      key={zone.key}
                      data-kind="zone"
                      data-key={zone.key}
                      opacity={zone.enabled ? 1 : 0.55}
                      className={tool === "select" && !zone.whole_view ? "cursor-move" : undefined}
                    >
                      <polygon
                        points={points.map((point) => `${point.x},${point.y}`).join(" ")}
                        fill={color}
                        fillOpacity={selected ? 0.2 : 0.1}
                        stroke={color}
                        strokeWidth={selected ? 2.5 : 1.5}
                        strokeDasharray={zone.suspended ? "6 4" : undefined}
                        strokeLinejoin="round"
                        pointerEvents={zone.whole_view || tool !== "select" ? "none" : undefined}
                      />
                      {zone.whole_view ? (
                        <Label x={10} y={14}>
                          {zone.name}
                        </Label>
                      ) : (
                        <Label x={center.x} y={center.y} anchor="middle">
                          {zone.name}
                        </Label>
                      )}
                    </g>
                  )
                })}
                {lines.map((line) => {
                  const selected = selectedLine?.key === line.key
                  const color = line.suspended ? "var(--status-warn)" : selected ? "var(--focus)" : ZONE_STROKE
                  const a = px(line.points[0])
                  const b = px(line.points[1])
                  const length = Math.max(1, distance(a, b))
                  const along = { x: (b.x - a.x) / length, y: (b.y - a.y) / length }
                  const side = inSide(line.points[0], line.points[1])
                  const mapped = { x: side[0] * size.width, y: side[1] * size.height }
                  const dot = mapped.x * along.x + mapped.y * along.y
                  const normal = { x: mapped.x - dot * along.x, y: mapped.y - dot * along.y }
                  const normalLength = Math.max(0.0001, Math.hypot(normal.x, normal.y))
                  const unit = { x: normal.x / normalLength, y: normal.y / normalLength }
                  const middle = { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 }
                  const tip = { x: middle.x + unit.x * ARROW_PX, y: middle.y + unit.y * ARROW_PX }
                  const base = { x: tip.x - unit.x * ARROW_HEAD_PX, y: tip.y - unit.y * ARROW_HEAD_PX }
                  const head = [
                    tip,
                    { x: base.x + along.x * 5, y: base.y + along.y * 5 },
                    { x: base.x - along.x * 5, y: base.y - along.y * 5 },
                  ]
                  return (
                    <g
                      key={line.key}
                      data-kind="line"
                      data-key={line.key}
                      opacity={line.enabled ? 1 : 0.55}
                      className={tool === "select" ? "cursor-move" : undefined}
                      pointerEvents={tool !== "select" ? "none" : undefined}
                    >
                      <line
                        x1={a.x}
                        y1={a.y}
                        x2={b.x}
                        y2={b.y}
                        stroke={color}
                        strokeWidth={selected ? 3 : 2}
                        strokeLinecap="round"
                        strokeDasharray={line.suspended ? "6 4" : undefined}
                      />
                      <line x1={a.x} y1={a.y} x2={b.x} y2={b.y} stroke="transparent" strokeWidth={16} />
                      <line x1={middle.x} y1={middle.y} x2={base.x} y2={base.y} stroke={color} strokeWidth={2} />
                      <polygon points={head.map((point) => `${point.x},${point.y}`).join(" ")} fill={color} />
                      <Label x={tip.x + unit.x * 12} y={tip.y + unit.y * 12} anchor="middle">
                        In
                      </Label>
                      <Label x={middle.x - unit.x * 14} y={middle.y - unit.y * 14} anchor="middle" muted>
                        Out
                      </Label>
                      <Label x={a.x - unit.x * 14} y={a.y - unit.y * 14} anchor="middle">
                        {line.name}
                      </Label>
                    </g>
                  )
                })}
                {tool === "select" && selectedZone && !selectedZone.whole_view ? (
                  <g>
                    {selectedZone.polygon.map((point, index) => {
                      const next = selectedZone.polygon[(index + 1) % selectedZone.polygon.length]
                      const middle = px([(point[0] + next[0]) / 2, (point[1] + next[1]) / 2])
                      return (
                        <g key={`mid-${index}`} data-kind="mid" data-key={selectedZone.key} data-index={index} className="cursor-copy">
                          <circle cx={middle.x} cy={middle.y} r={HIT_PX - 4} fill="transparent" />
                          <circle cx={middle.x} cy={middle.y} r={MID_PX} fill="var(--focus)" fillOpacity={0.75} pointerEvents="none" />
                        </g>
                      )
                    })}
                    {selectedZone.polygon.map((point, index) => {
                      const at = px(point)
                      return (
                        <g key={`vertex-${index}`} data-kind="vertex" data-key={selectedZone.key} data-index={index} className="cursor-move">
                          <circle cx={at.x} cy={at.y} r={HIT_PX} fill="transparent" />
                          <circle
                            cx={at.x}
                            cy={at.y}
                            r={HANDLE_PX}
                            fill={vertex === index ? "var(--focus)" : "var(--surface)"}
                            stroke="var(--focus)"
                            strokeWidth={2}
                            pointerEvents="none"
                          />
                        </g>
                      )
                    })}
                  </g>
                ) : null}
                {tool === "select" && selectedLine
                  ? selectedLine.points.map((point, index) => {
                      const at = px(point)
                      return (
                        <g key={`end-${index}`} data-kind="end" data-key={selectedLine.key} data-index={index} className="cursor-move">
                          <circle cx={at.x} cy={at.y} r={HIT_PX} fill="transparent" />
                          <circle
                            cx={at.x}
                            cy={at.y}
                            r={HANDLE_PX}
                            fill="var(--surface)"
                            stroke="var(--focus)"
                            strokeWidth={2}
                            pointerEvents="none"
                          />
                        </g>
                      )
                    })
                  : null}
                {tool === "zone" && draft.length > 0 ? (
                  <g pointerEvents="none">
                    {draft.length >= 3 ? (
                      <polygon
                        points={draft.map((point) => `${px(point).x},${px(point).y}`).join(" ")}
                        fill="var(--focus)"
                        fillOpacity={0.12}
                        stroke="none"
                      />
                    ) : null}
                    <polyline
                      points={[...draft, ...(hover ? [hover] : [])]
                        .map((point) => `${px(point).x},${px(point).y}`)
                        .join(" ")}
                      fill="none"
                      stroke="var(--focus)"
                      strokeWidth={2}
                      strokeDasharray="5 4"
                      strokeLinejoin="round"
                    />
                    {draft.map((point, index) => {
                      const at = px(point)
                      const closing = index === 0 && draft.length >= 3
                      return (
                        <circle
                          key={index}
                          cx={at.x}
                          cy={at.y}
                          r={closing ? HANDLE_PX + 2 : HANDLE_PX - 1}
                          fill={closing ? "var(--focus)" : "var(--surface)"}
                          stroke="var(--focus)"
                          strokeWidth={2}
                        />
                      )
                    })}
                  </g>
                ) : null}
                {tool === "line" && draft.length > 0 ? (
                  <g pointerEvents="none">
                    {hover ? (
                      <line
                        x1={px(draft[0]).x}
                        y1={px(draft[0]).y}
                        x2={px(hover).x}
                        y2={px(hover).y}
                        stroke="var(--focus)"
                        strokeWidth={2}
                        strokeDasharray="5 4"
                      />
                    ) : null}
                    <circle
                      cx={px(draft[0]).x}
                      cy={px(draft[0]).y}
                      r={HANDLE_PX - 1}
                      fill="var(--surface)"
                      stroke="var(--focus)"
                      strokeWidth={2}
                    />
                  </g>
                ) : null}
              </>
            ) : null}
          </svg>
        </div>
      </div>
      {hint ? (
        <div className="pointer-events-none absolute inset-x-3 top-3 flex justify-center">
          <div className="max-w-md rounded-md border border-hairline bg-surface/90 px-3 py-2 text-center text-[12px] text-text-2">
            {hint}
          </div>
        </div>
      ) : null}
    </div>
  )
}
