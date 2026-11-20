"use client"

import * as React from "react"

import {
  STATUS_LABELS,
  STATUS_TONES,
  TONE_CLASSES,
  bucketTone,
  formatAxisTime,
  formatLatency,
  formatPercent,
  formatSpan,
} from "@/lib/health"
import type { HealthBucket, HealthRange, TargetStatus } from "@/lib/types"
import { cn } from "@/lib/utils"

const SPARK_HEIGHT = 32
const CHART_HEIGHT = 100
const SCALE_FLOOR_MS = 5

export function HealthDot({ status, className }: { status: TargetStatus; className?: string }) {
  return (
    <span
      role="img"
      aria-label={STATUS_LABELS[status]}
      className={cn("inline-block size-2 shrink-0 rounded-full", TONE_CLASSES[STATUS_TONES[status]], className)}
    />
  )
}

function scaleMax(buckets: HealthBucket[]): number {
  let max = SCALE_FLOOR_MS
  for (const bucket of buckets) {
    if (bucket.latency_ms !== null && bucket.latency_ms > max) max = bucket.latency_ms
  }
  return max
}

function linePaths(buckets: HealthBucket[], height: number, max: number, inset: number) {
  const y = (value: number) => height - inset - (value / max) * (height - inset * 2)
  const lines: string[] = []
  const areas: string[] = []
  let run: { x: number; y: number }[] = []
  const flush = () => {
    if (run.length === 0) return
    const points = run.length === 1 ? [{ x: run[0].x - 0.5, y: run[0].y }, { x: run[0].x + 0.5, y: run[0].y }] : run
    lines.push(points.map((point, index) => `${index ? "L" : "M"}${point.x} ${point.y}`).join(" "))
    const first = points[0]
    const last = points[points.length - 1]
    areas.push(
      `M${first.x} ${height} ${points.map((point) => `L${point.x} ${point.y}`).join(" ")} L${last.x} ${height} Z`,
    )
    run = []
  }
  buckets.forEach((bucket, index) => {
    if (bucket.latency_ms === null) {
      flush()
      return
    }
    run.push({ x: index + 0.5, y: y(bucket.latency_ms) })
  })
  flush()
  return { line: lines.join(" "), area: areas.join(" ") }
}

export function AvailabilityStrip({
  buckets,
  range,
  className,
}: {
  buckets: HealthBucket[]
  range: HealthRange
  className?: string
}) {
  const down = buckets.filter((bucket) => bucketTone(bucket) === "err").length
  const partial = buckets.filter((bucket) => bucketTone(bucket) === "warn").length
  return (
    <div
      role="img"
      aria-label={`Availability: ${down} periods down and ${partial} partly down out of ${buckets.length}`}
      className={cn("grid h-3 gap-px", className)}
      style={{ gridTemplateColumns: `repeat(${Math.max(1, buckets.length)}, minmax(0, 1fr))` }}
    >
      {buckets.map((bucket) => {
        const tone = bucketTone(bucket)
        return (
          <span
            key={bucket.start}
            title={`${formatAxisTime(bucket.start, range)} ${bucket.availability === null ? "no data" : formatPercent(bucket.availability)}`}
            className={cn("rounded-[1px]", tone === "off" ? "bg-surface-3" : TONE_CLASSES[tone])}
          />
        )
      })}
    </div>
  )
}

export function Sparkline({ buckets, className }: { buckets: HealthBucket[]; className?: string }) {
  const max = scaleMax(buckets)
  const { line, area } = linePaths(buckets, SPARK_HEIGHT, max, 2)
  return (
    <svg
      aria-hidden
      viewBox={`0 0 ${Math.max(1, buckets.length)} ${SPARK_HEIGHT}`}
      preserveAspectRatio="none"
      className={cn("h-8 w-full text-text-2", className)}
    >
      {area ? <path d={area} fill="currentColor" opacity={0.08} /> : null}
      {line ? (
        <path
          d={line}
          fill="none"
          stroke="currentColor"
          strokeWidth={1.25}
          strokeLinejoin="round"
          vectorEffect="non-scaling-stroke"
        />
      ) : null}
    </svg>
  )
}

function readout(bucket: HealthBucket, range: HealthRange): string {
  const start = formatAxisTime(bucket.start, range)
  if (bucket.availability === null) return `${start}, no data`
  return `${start}, ${formatPercent(bucket.availability)} up, ${formatLatency(bucket.latency_ms)}`
}

export function LatencyChart({
  buckets,
  range,
  bucketSeconds,
}: {
  buckets: HealthBucket[]
  range: HealthRange
  bucketSeconds: number
}) {
  const [hover, setHover] = React.useState<number | null>(null)
  const max = scaleMax(buckets)
  const { line, area } = linePaths(buckets, CHART_HEIGHT, max, 4)
  const count = Math.max(1, buckets.length)
  const middle = buckets[Math.floor(buckets.length / 2)]
  const hovered = hover !== null ? buckets[hover] : null

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
          {hovered ? readout(hovered, range) : `Average latency per ${formatSpan(bucketSeconds)}`}
        </span>
        <span className="shrink-0">{formatLatency(max)}</span>
      </div>
      <div className="relative h-36 overflow-hidden rounded-md border border-hairline bg-background">
        <svg
          role="img"
          aria-label="Latency over the range"
          viewBox={`0 0 ${count} ${CHART_HEIGHT}`}
          preserveAspectRatio="none"
          className="absolute inset-0 h-full w-full touch-none text-foreground"
          onPointerMove={track}
          onPointerDown={track}
          onPointerLeave={() => setHover(null)}
        >
          {buckets.map((bucket, index) => {
            const tone = bucketTone(bucket)
            if (tone !== "warn" && tone !== "err") return null
            return (
              <rect
                key={bucket.start}
                x={index}
                y={0}
                width={1}
                height={CHART_HEIGHT}
                fill={tone === "err" ? "var(--status-err)" : "var(--status-warn)"}
                opacity={0.22}
              />
            )
          })}
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
          {area ? <path d={area} fill="currentColor" opacity={0.07} /> : null}
          {line ? (
            <path
              d={line}
              fill="none"
              stroke="currentColor"
              strokeWidth={1.5}
              strokeLinejoin="round"
              vectorEffect="non-scaling-stroke"
            />
          ) : null}
          {hover !== null ? (
            <line
              x1={hover + 0.5}
              x2={hover + 0.5}
              y1={0}
              y2={CHART_HEIGHT}
              stroke="var(--text-3)"
              strokeWidth={1}
              vectorEffect="non-scaling-stroke"
            />
          ) : null}
        </svg>
      </div>
      <div className="flex justify-between font-data text-[10px] text-text-3">
        <span>{buckets[0] ? formatAxisTime(buckets[0].start, range) : ""}</span>
        <span>{middle ? formatAxisTime(middle.start, range) : ""}</span>
        <span>now</span>
      </div>
    </div>
  )
}
