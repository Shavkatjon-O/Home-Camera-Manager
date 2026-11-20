"use client"

import { CountsChart, Legend } from "@/components/counts/bar-chart"
import { labelName } from "@/lib/events"
import { HOURS_PER_DAY, formatHour, hourSeries, lineTotal, type CountLine, type CountsResponse } from "@/lib/counts"

const HOUR_NAMES = Array.from({ length: HOURS_PER_DAY }, (_, hour) => `${formatHour(hour)} to ${formatHour((hour + 1) % HOURS_PER_DAY)}`)

function Figure({ label, value }: { label: string; value: number }) {
  return (
    <div className="flex min-w-0 flex-col gap-0.5">
      <span className="font-data text-[22px] leading-none text-foreground">{value}</span>
      <span className="text-[11px] text-text-3">{label}</span>
    </div>
  )
}

export function LineCard({
  line,
  response,
  label,
}: {
  line: CountLine
  response: CountsResponse
  label: string | null
}) {
  const total = lineTotal(response, line.uuid, label)
  const series = hourSeries(response, new Set([line.uuid]), label)
  const length = series.slots.length
  const names =
    length === HOURS_PER_DAY ? HOUR_NAMES : series.slots.map((_, hour) => `Hour ${hour + 1}`)
  const scope = label ? labelName(label) : "All labels"
  return (
    <section
      aria-label={`${line.name} counts`}
      data-testid="counts-line"
      className="flex min-w-0 flex-col gap-3 rounded-lg border border-hairline bg-surface p-4"
    >
      <div className="flex items-start justify-between gap-3">
        <div className="flex min-w-0 flex-col gap-1">
          <span className="truncate text-[14px] text-foreground">{line.name}</span>
          <span className="truncate text-[12px] text-text-2">{line.view_name}</span>
        </div>
        <div className="flex shrink-0 items-start gap-5">
          <Figure label="In" value={total.in} />
          <Figure label="Out" value={total.out} />
        </div>
      </div>
      <div className="flex items-center justify-between gap-2">
        <span className="text-[11px] text-text-3">{scope} per hour</span>
        <Legend />
      </div>
      <CountsChart
        series={series}
        names={names}
        axis={["00:00", "06:00", "12:00", "18:00", "24:00"]}
        caption="Crossings per hour"
        ariaLabel={`${line.name} crossings per hour`}
      />
    </section>
  )
}
