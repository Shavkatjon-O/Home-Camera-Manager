"use client"

import { AvailabilityStrip, HealthDot, Sparkline } from "@/components/health/charts"
import { Chip } from "@/components/shell/primitives"
import { STATUS_LABELS, formatLatency, formatPercent, viaLine } from "@/lib/health"
import type { HealthRange, TargetHealth } from "@/lib/types"
import { cn } from "@/lib/utils"

function Figure({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex min-w-0 flex-col gap-0.5">
      <span className="truncate font-data text-[13px] text-foreground">{value}</span>
      <span className="text-[11px] text-text-3">{label}</span>
    </div>
  )
}

export function TargetCard({
  target,
  range,
  selected,
  onSelect,
}: {
  target: TargetHealth
  range: HealthRange
  selected: boolean
  onSelect: (uuid: string) => void
}) {
  return (
    <button
      type="button"
      aria-pressed={selected}
      data-testid="health-card"
      onClick={() => onSelect(target.uuid)}
      className={cn(
        "flex min-w-0 flex-col gap-3 rounded-lg border bg-surface p-4 text-left transition-colors",
        selected ? "border-hairline-strong bg-surface-2" : "border-hairline hover:border-hairline-strong",
      )}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="flex min-w-0 flex-col gap-1">
          <div className="flex min-w-0 items-center gap-2">
            <HealthDot status={target.status} />
            <span className="truncate text-[14px] text-foreground">{target.name}</span>
            {target.status !== "up" ? <Chip className="h-5 px-1.5 text-[10px]">{STATUS_LABELS[target.status]}</Chip> : null}
          </div>
          <span className="truncate font-data text-[11px] text-text-3">
            {target.host}:{target.port}
          </span>
          <span className="truncate text-[12px] text-text-2">{viaLine(target)}</span>
        </div>
        <div className="flex shrink-0 flex-col items-end gap-0.5">
          <span className="font-data text-[22px] leading-none text-foreground">{formatPercent(target.uptime_percent)}</span>
          <span className="text-[11px] text-text-3">uptime</span>
        </div>
      </div>
      <div className="grid grid-cols-3 gap-3">
        <Figure label="Typical" value={formatLatency(target.latency.p50_ms)} />
        <Figure label="p95" value={formatLatency(target.latency.p95_ms)} />
        <Figure label={target.outage_count === 1 ? "Outage" : "Outages"} value={String(target.outage_count)} />
      </div>
      <AvailabilityStrip buckets={target.buckets} range={range} />
      <Sparkline buckets={target.buckets} />
    </button>
  )
}
