"use client"

import * as React from "react"

import { CountsChart, Legend } from "@/components/counts/bar-chart"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { labelName } from "@/lib/events"
import { DAILY_SPAN, dayDates, daySeries, formatShortDay, type CountsRange, type CountsResponse } from "@/lib/counts"
import type { CountLine } from "@/lib/counts"

const ALL = "all"

export function DailySection({
  lines,
  response,
  range,
  label,
}: {
  lines: CountLine[]
  response: CountsResponse | null
  range: CountsRange
  label: string | null
}) {
  const [selected, setSelected] = React.useState(ALL)
  const active = selected === ALL || lines.some((line) => line.uuid === selected) ? selected : ALL
  const dates = dayDates(range)
  const names = dates.map(formatShortDay)
  const series = response
    ? daySeries(response, range, active === ALL ? null : new Set([active]), label)
    : null
  const middle = dates[Math.floor(dates.length / 2)]
  const axis = [names[0], middle ? formatShortDay(middle) : "", names[names.length - 1]]
  const scope = label ? labelName(label) : "All labels"

  return (
    <section aria-label="Daily counts" className="flex flex-col gap-3 rounded-lg border border-hairline bg-surface p-4">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <div className="flex flex-col gap-0.5">
          <h2 className="text-[14px] text-foreground">Last {DAILY_SPAN} days</h2>
          <span className="text-[11px] text-text-3">{scope} per day</span>
        </div>
        <div className="flex items-center gap-3">
          <Legend />
          <Select value={active} onValueChange={setSelected}>
            <SelectTrigger aria-label="Line" className="w-44 font-mono text-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value={ALL} className="font-mono text-xs">
                All lines
              </SelectItem>
              {lines.map((line) => (
                <SelectItem key={line.uuid} value={line.uuid} className="font-mono text-xs">
                  {line.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>
      {series ? (
        <CountsChart
          series={series}
          names={names}
          axis={axis}
          caption={`${series.total.in} in, ${series.total.out} out in ${DAILY_SPAN} days`}
          ariaLabel="Crossings per day"
        />
      ) : (
        <div className="flex h-36 items-center justify-center text-[13px] text-text-3">Loading daily counts</div>
      )}
    </section>
  )
}
