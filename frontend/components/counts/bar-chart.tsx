"use client"

import * as React from "react"

import type { Series } from "@/lib/counts"

const CHART_HEIGHT = 100
const SCALE_FLOOR = 4
const IN_COLOR = "var(--status-ok)"
const OUT_COLOR = "var(--status-warn)"

export function Legend() {
  return (
    <span className="flex shrink-0 items-center gap-3 font-data text-[11px] text-text-3">
      <span className="flex items-center gap-1.5">
        <span aria-hidden className="inline-block size-2 rounded-sm bg-status-ok" />
        In
      </span>
      <span className="flex items-center gap-1.5">
        <span aria-hidden className="inline-block size-2 rounded-sm bg-status-warn" />
        Out
      </span>
    </span>
  )
}

export function CountsChart({
  series,
  names,
  axis,
  caption,
  ariaLabel,
}: {
  series: Series
  names: string[]
  axis: string[]
  caption: string
  ariaLabel: string
}) {
  const [hover, setHover] = React.useState<number | null>(null)
  const count = Math.max(1, series.slots.length)
  let max = SCALE_FLOOR
  for (const slot of series.slots) max = Math.max(max, slot.in, slot.out)
  const y = (value: number) => (value / max) * (CHART_HEIGHT - 4)
  const hovered = hover !== null ? series.slots[hover] : null

  const track = (event: React.PointerEvent<SVGSVGElement>) => {
    const rect = event.currentTarget.getBoundingClientRect()
    if (rect.width <= 0) return
    const index = Math.floor(((event.clientX - rect.left) / rect.width) * count)
    setHover(Math.min(count - 1, Math.max(0, index)))
  }

  return (
    <div className="flex flex-col gap-1.5">
      <div className="flex min-h-4 items-baseline justify-between gap-2 font-data text-[11px] text-text-3">
        <span className="truncate text-text-2">
          {hover !== null && hovered
            ? `${names[hover]}, ${hovered.in} in, ${hovered.out} out`
            : caption}
        </span>
        <span className="shrink-0">{max}</span>
      </div>
      <div className="relative h-36 overflow-hidden rounded-md border border-hairline bg-background">
        <svg
          role="img"
          aria-label={ariaLabel}
          viewBox={`0 0 ${count} ${CHART_HEIGHT}`}
          preserveAspectRatio="none"
          className="absolute inset-0 h-full w-full touch-none"
          onPointerMove={track}
          onPointerDown={track}
          onPointerLeave={() => setHover(null)}
        >
          {[0.25, 0.5, 0.75].map((fraction) => (
            <line
              key={fraction}
              x1={0}
              x2={count}
              y1={CHART_HEIGHT * fraction}
              y2={CHART_HEIGHT * fraction}
              stroke="var(--border)"
              strokeWidth={1}
              vectorEffect="non-scaling-stroke"
            />
          ))}
          {hover !== null ? (
            <rect x={hover} y={0} width={1} height={CHART_HEIGHT} fill="var(--text-3)" opacity={0.12} />
          ) : null}
          {series.slots.map((slot, index) => (
            <g key={index}>
              {slot.in > 0 ? (
                <rect
                  x={index + 0.12}
                  y={CHART_HEIGHT - y(slot.in)}
                  width={0.36}
                  height={y(slot.in)}
                  fill={IN_COLOR}
                />
              ) : null}
              {slot.out > 0 ? (
                <rect
                  x={index + 0.52}
                  y={CHART_HEIGHT - y(slot.out)}
                  width={0.36}
                  height={y(slot.out)}
                  fill={OUT_COLOR}
                />
              ) : null}
            </g>
          ))}
        </svg>
      </div>
      <div className="flex justify-between font-data text-[10px] text-text-3">
        {axis.map((text, index) => (
          <span key={index}>{text}</span>
        ))}
      </div>
    </div>
  )
}
