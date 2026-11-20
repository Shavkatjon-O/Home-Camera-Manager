"use client"

import * as React from "react"
import Link from "next/link"
import { ChevronLeftIcon, ChevronRightIcon, CircleAlertIcon, PlusIcon, SigmaIcon } from "lucide-react"

import { AreaCard } from "@/components/counts/area-card"
import { AreaFormDialog, DeleteAreaDialog, OccupancyDialog } from "@/components/counts/area-dialogs"
import { DailySection } from "@/components/counts/daily-section"
import { LineCard } from "@/components/counts/line-card"
import { CardGrid, PageContent, PageFrame } from "@/components/shell/page-frame"
import { IconButton } from "@/components/shell/icon-button"
import { Chip, EmptyState, LoadingState } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { errorMessage, isAbort } from "@/lib/api"
import {
  addDays,
  dailyRange,
  dayRange,
  fetchAreas,
  fetchCounts,
  formatDay,
  presentLabels,
  sameDay,
  startOfDay,
  type Area,
  type CountsResponse,
} from "@/lib/counts"
import { labelName } from "@/lib/events"

const REFRESH_MS = 30000
const ALL = "all"

/** The Counts page: line crossings by hour for one day, and how many are inside each area. */
export function CountsView() {
  const [day, setDay] = React.useState(() => startOfDay(new Date()))
  const [label, setLabel] = React.useState(ALL)
  const [tick, setTick] = React.useState(0)
  const [reload, setReload] = React.useState(0)
  const [hourly, setHourly] = React.useState<CountsResponse | null>(null)
  const [hourlyDay, setHourlyDay] = React.useState<number | null>(null)
  const [daily, setDaily] = React.useState<CountsResponse | null>(null)
  const [dailyDay, setDailyDay] = React.useState<number | null>(null)
  const [areas, setAreas] = React.useState<Area[] | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const [areasError, setAreasError] = React.useState<string | null>(null)
  const [formOpen, setFormOpen] = React.useState(false)
  const [editing, setEditing] = React.useState<Area | null>(null)
  const [setting, setSetting] = React.useState<Area | null>(null)
  const [deleting, setDeleting] = React.useState<Area | null>(null)

  React.useEffect(() => {
    const refresh = () => {
      if (document.visibilityState === "visible") setTick((value) => value + 1)
    }
    const timer = window.setInterval(refresh, REFRESH_MS)
    document.addEventListener("visibilitychange", refresh)
    return () => {
      window.clearInterval(timer)
      document.removeEventListener("visibilitychange", refresh)
    }
  }, [])

  const dayTime = day.getTime()

  React.useEffect(() => {
    const controller = new AbortController()
    fetchCounts(dayRange(new Date(dayTime)), controller.signal)
      .then((data) => {
        setHourly(data)
        setHourlyDay(dayTime)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(errorMessage(err))
      })
    return () => controller.abort()
  }, [dayTime, tick, reload])

  React.useEffect(() => {
    const controller = new AbortController()
    fetchCounts(dailyRange(new Date(dayTime)), controller.signal)
      .then((data) => {
        setDaily(data)
        setDailyDay(dayTime)
      })
      .catch(() => undefined)
    return () => controller.abort()
  }, [dayTime, tick, reload])

  React.useEffect(() => {
    const controller = new AbortController()
    fetchAreas(controller.signal)
      .then((data) => {
        setAreas(data.items)
        setAreasError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setAreasError(errorMessage(err))
      })
    return () => controller.abort()
  }, [tick, reload])

  const changed = () => setReload((value) => value + 1)
  const today = startOfDay(new Date())
  const isToday = sameDay(day, today)
  const shown = hourlyDay === dayTime ? hourly : null
  const lines = React.useMemo(() => hourly?.lines ?? [], [hourly])
  const labels = React.useMemo(() => {
    const found = new Set<string>(hourly ? presentLabels(hourly) : [])
    if (label !== ALL) found.add(label)
    return [...found]
  }, [hourly, label])
  const activeLabel = label === ALL ? null : label
  const dailyRangeValue = dailyRange(day)

  const openAdd = () => {
    setEditing(null)
    setFormOpen(true)
  }

  const actions = (
    <>
      <div role="group" aria-label="Day" className="flex items-center gap-1">
        <IconButton label="Previous day" onClick={() => setDay((value) => addDays(value, -1))}>
          <ChevronLeftIcon />
        </IconButton>
        <IconButton label="Next day" disabled={isToday} onClick={() => setDay((value) => addDays(value, 1))}>
          <ChevronRightIcon />
        </IconButton>
        <Button variant="outline" disabled={isToday} onClick={() => setDay(startOfDay(new Date()))}>
          Today
        </Button>
      </div>
      <Select value={label} onValueChange={setLabel}>
        <SelectTrigger aria-label="Label" className="w-36 font-mono text-xs">
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value={ALL} className="font-mono text-xs">
            All labels
          </SelectItem>
          {labels.map((item) => (
            <SelectItem key={item} value={item} className="font-mono text-xs">
              {labelName(item)}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      <Button onClick={openAdd} aria-label="Add area">
        <PlusIcon />
        <span className="hidden sm:inline">Add area</span>
      </Button>
    </>
  )

  let content: React.ReactNode
  if (!hourly && error) {
    content = (
      <EmptyState icon={<CircleAlertIcon />} title="Cannot load counts">
        <span className="font-data text-xs">{error}</span>
        <Button variant="outline" onClick={changed}>
          Try again
        </Button>
      </EmptyState>
    )
  } else if (!hourly) {
    content = <LoadingState label="Loading counts" />
  } else {
    content = (
      <PageContent>
        <p className="font-data text-[11px] text-text-3">
          {formatDay(day)}
          {error ? <span className="ml-3 text-danger">{error}</span> : null}
        </p>
        <section className="flex flex-col gap-2">
          <h2 className="text-xs text-text-3">Areas</h2>
          {areasError && !areas ? (
            <p className="text-[13px] text-danger">{areasError}</p>
          ) : areas === null ? (
            <LoadingState label="Loading areas" className="min-h-24" />
          ) : areas.length === 0 ? (
            <div className="flex flex-col items-start gap-2 rounded-lg border border-hairline bg-surface p-4">
              <span className="text-[13px] text-text-3">
                An area is a place bounded by lines, such as a house behind its entrance door, and shows how many are
                inside.
              </span>
              <Button variant="outline" onClick={openAdd}>
                <PlusIcon />
                Add area
              </Button>
            </div>
          ) : (
            <CardGrid>
              {areas.map((area) => (
                <AreaCard
                  key={area.uuid}
                  area={area}
                  onEdit={(item) => {
                    setEditing(item)
                    setFormOpen(true)
                  }}
                  onDelete={setDeleting}
                  onSet={setSetting}
                />
              ))}
            </CardGrid>
          )}
        </section>
        {lines.length === 0 ? (
          <EmptyState icon={<SigmaIcon />} title="No lines to count yet">
            <span>Draw a line on a camera&apos;s analytics view to count crossings</span>
            <Button asChild variant="outline">
              <Link href="/cameras/">Go to cameras</Link>
            </Button>
          </EmptyState>
        ) : (
          <>
            <section className="flex flex-col gap-2">
              <div className="flex items-baseline gap-2">
                <h2 className="text-xs text-text-3">Lines</h2>
                <span className="font-data text-[11px] text-text-3">{lines.length}</span>
              </div>
              {shown ? (
                <CardGrid>
                  {shown.lines.map((line) => (
                    <LineCard key={line.uuid} line={line} response={shown} label={activeLabel} />
                  ))}
                </CardGrid>
              ) : (
                <LoadingState label="Loading counts" className="min-h-24" />
              )}
            </section>
            <DailySection
              lines={lines}
              response={dailyDay === dayTime ? daily : null}
              range={dailyRangeValue}
              label={activeLabel}
            />
          </>
        )}
      </PageContent>
    )
  }

  return (
    <PageFrame
      status={areas && areas.length > 0 ? <Chip>{areas.length === 1 ? "1 area" : `${areas.length} areas`}</Chip> : null}
      actions={actions}
      contained
    >
      <div className="flex min-h-0 min-w-0 flex-1">
        <main className="@container min-h-0 min-w-0 flex-1 overflow-y-auto">{content}</main>
      </div>
      <AreaFormDialog open={formOpen} onOpenChange={setFormOpen} area={editing} lines={lines} onSaved={changed} />
      <OccupancyDialog area={setting} onOpenChange={(open) => !open && setSetting(null)} onSaved={changed} />
      <DeleteAreaDialog area={deleting} onOpenChange={(open) => !open && setDeleting(null)} onDeleted={changed} />
    </PageFrame>
  )
}
