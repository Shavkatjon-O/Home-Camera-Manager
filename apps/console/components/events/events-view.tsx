"use client"

import * as React from "react"
import { useSearchParams } from "next/navigation"
import { ChevronLeftIcon, ChevronRightIcon, CircleAlertIcon, ScanEyeIcon, XIcon } from "lucide-react"

import { EventCountRow } from "@/components/events/event-counts"
import { AlertMark, EventDuration, EventThumb, KindChip, LabelChip } from "@/components/events/event-parts"
import { EventPanel } from "@/components/events/event-panel"
import { useEvents } from "@/components/events/events-provider"
import { SourceChip } from "@/components/events/source-chip"
import { FaceChip } from "@/components/people/face-parts"
import { PageFrame, ToolbarRow } from "@/components/shell/page-frame"
import { IconButton } from "@/components/shell/icon-button"
import { Chip, EmptyState, LoadingState } from "@/components/shell/primitives"
import { useSession } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { api, errorMessage, isAbort } from "@/lib/api"
import {
  EVENT_KINDS,
  EVENT_LABELS,
  KIND_LABELS,
  clearUnseenAlerts,
  dayRange,
  eventPlace,
  labelName,
} from "@/lib/events"
import { formatMoment } from "@/lib/health"
import type { CameraEvent, EventKind, EventQuery, Page } from "@/lib/types"
import { cn } from "@/lib/utils"

const PAGE_SIZE = 50
const ALL = "all"
const PLATE_MAX = 20
const PLATE_DELAY = 400

function matches(event: CameraEvent, query: EventQuery): boolean {
  if (query.camera_uuid && event.camera_uuid !== query.camera_uuid) return false
  if (query.kind && event.kind !== query.kind) return false
  if (query.label && event.label !== query.label) return false
  if (query.plate) return false
  const started = Date.parse(event.started_at)
  if (query.from && started < Date.parse(query.from)) return false
  if (query.to && started >= Date.parse(query.to)) return false
  return true
}

function EventRow({
  event,
  selected,
  onSelect,
}: {
  event: CameraEvent
  selected: boolean
  onSelect: (uuid: string) => void
}) {
  const place = eventPlace(event)
  return (
    <li>
      <button
        type="button"
        aria-current={selected ? "true" : undefined}
        onClick={() => onSelect(event.uuid)}
        className={cn(
          "flex w-full items-center gap-3 border-b border-hairline px-3 py-2 text-left transition-colors hover:bg-surface-2 sm:px-4",
          selected && "bg-surface-3 hover:bg-surface-3",
        )}
      >
        <EventThumb event={event} className="w-24 sm:w-32" />
        <div className="flex min-w-0 flex-1 flex-col gap-1">
          <div className="flex min-w-0 items-center gap-2">
            <span className="truncate text-[13px] text-foreground">{event.camera_name ?? "Removed camera"}</span>
            <KindChip event={event} />
            {event.face ? <FaceChip face={event.face} className="h-5 px-1.5 text-[10px]" /> : <LabelChip event={event} />}
            <AlertMark event={event} />
          </div>
          <div className="flex min-w-0 items-baseline gap-2">
            <span className="shrink-0 font-data text-[12px] text-text-2">{formatMoment(event.started_at)}</span>
            {place ? <span className="truncate text-[12px] text-text-3">{place}</span> : null}
          </div>
        </div>
        <EventDuration event={event} />
      </button>
    </li>
  )
}

function Filters({
  camera,
  kind,
  label,
  plate,
  day,
  onCamera,
  onKind,
  onLabel,
  onPlate,
  onDay,
  onClear,
}: {
  camera: string
  kind: string
  label: string
  plate: string
  day: string
  onCamera: (value: string) => void
  onKind: (value: string) => void
  onLabel: (value: string) => void
  onPlate: (value: string) => void
  onDay: (value: string) => void
  onClear: () => void
}) {
  const { cameras } = useSession()
  const filtered = camera !== ALL || kind !== ALL || label !== ALL || plate !== "" || day !== ""
  return (
    <ToolbarRow>
      <Select value={camera} onValueChange={onCamera}>
        <SelectTrigger aria-label="Camera" className="w-40">
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value={ALL}>All cameras</SelectItem>
          {cameras.map((item) => (
            <SelectItem key={item.uuid} value={item.uuid}>
              {item.name}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      <Select value={kind} onValueChange={onKind}>
        <SelectTrigger aria-label="Kind" className="w-36">
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value={ALL}>All kinds</SelectItem>
          {EVENT_KINDS.map((item) => (
            <SelectItem key={item} value={item}>
              {KIND_LABELS[item]}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      <Select value={label} onValueChange={onLabel}>
        <SelectTrigger aria-label="Label" className="w-32">
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value={ALL}>All labels</SelectItem>
          {EVENT_LABELS.map((item) => (
            <SelectItem key={item} value={item}>
              {labelName(item)}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      <Input
        aria-label="Plate"
        placeholder="Plate"
        value={plate}
        maxLength={PLATE_MAX}
        autoComplete="off"
        onChange={(event) => onPlate(event.target.value.toUpperCase().replace(/[^A-Z0-9]/g, ""))}
        className="h-8 w-28 font-data text-[12px]"
      />
      <Input
        type="date"
        aria-label="Day"
        value={day}
        onChange={(event) => onDay(event.target.value)}
        className="h-8 w-40 font-data text-[12px]"
      />
      {filtered ? (
        <Button variant="ghost" size="sm" onClick={onClear}>
          <XIcon />
          Clear
        </Button>
      ) : null}
    </ToolbarRow>
  )
}

function EventsView() {
  const params = useSearchParams()
  const { connected, version, sources, subscribe } = useEvents()
  const [camera, setCamera] = React.useState(params.get("camera") ?? ALL)
  const [kind, setKind] = React.useState(ALL)
  const [label, setLabel] = React.useState(ALL)
  const [plate, setPlate] = React.useState("")
  const [plateQuery, setPlateQuery] = React.useState("")
  const [day, setDay] = React.useState("")
  const [page, setPage] = React.useState(1)
  const [reload, setReload] = React.useState(0)
  const [data, setData] = React.useState<Page<CameraEvent> | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const [selected, setSelected] = React.useState<string | null>(params.get("event"))
  const [detail, setDetail] = React.useState<CameraEvent | null>(null)

  const query = React.useMemo<EventQuery>(() => {
    const range = day ? dayRange(day) : null
    return {
      camera_uuid: camera === ALL ? undefined : camera,
      kind: kind === ALL ? undefined : (kind as EventKind),
      label: label === ALL ? undefined : label,
      plate: plateQuery || undefined,
      from: range?.from,
      to: range?.to,
    }
  }, [camera, kind, label, plateQuery, day])

  React.useEffect(() => {
    const timer = window.setTimeout(() => {
      setPlateQuery(plate)
      setPage(1)
    }, PLATE_DELAY)
    return () => window.clearTimeout(timer)
  }, [plate])

  React.useEffect(() => {
    clearUnseenAlerts()
    const onVisible = () => {
      if (document.visibilityState === "visible") clearUnseenAlerts()
    }
    document.addEventListener("visibilitychange", onVisible)
    return () => document.removeEventListener("visibilitychange", onVisible)
  }, [])

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .listEvents({ ...query, page, page_size: PAGE_SIZE }, controller.signal)
      .then((result) => {
        if (result.items.length === 0 && result.total > 0 && page > 1) {
          setPage(Math.max(1, Math.ceil(result.total / PAGE_SIZE)))
          return
        }
        setData(result)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(errorMessage(err))
      })
    return () => controller.abort()
  }, [query, page, reload, version])

  React.useEffect(
    () =>
      subscribe((event) => {
        setData((current) => {
          if (!current) return current
          const index = current.items.findIndex((item) => item.uuid === event.uuid)
          if (index >= 0) {
            const items = [...current.items]
            items[index] = event
            return { ...current, items }
          }
          if (page !== 1 || !matches(event, query)) return current
          return { ...current, items: [event, ...current.items].slice(0, PAGE_SIZE), total: current.total + 1 }
        })
        setDetail((current) => (current && current.uuid === event.uuid ? event : current))
      }),
    [subscribe, page, query],
  )

  const listed = selected ? (data?.items.find((item) => item.uuid === selected) ?? null) : null

  React.useEffect(() => {
    if (!selected || listed) return
    const controller = new AbortController()
    api
      .getEvent(selected, controller.signal)
      .then(setDetail)
      .catch(() => undefined)
    return () => controller.abort()
  }, [selected, listed])

  const selectedEvent = listed ?? (detail && detail.uuid === selected ? detail : null)

  const changeFilter = (setter: (value: string) => void) => (value: string) => {
    setter(value)
    setPage(1)
  }

  const clear = () => {
    setCamera(ALL)
    setKind(ALL)
    setLabel(ALL)
    setPlate("")
    setPlateQuery("")
    setDay("")
    setPage(1)
  }

  const select = (uuid: string) => setSelected((current) => (current === uuid ? null : uuid))

  React.useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      if (event.key !== "Escape") return
      const target = event.target as HTMLElement | null
      if (target?.closest("input, [role='listbox'], [role='dialog']")) return
      setSelected(null)
    }
    window.addEventListener("keydown", onKey)
    return () => window.removeEventListener("keydown", onKey)
  }, [])

  const total = data?.total ?? 0
  const pageCount = Math.max(1, Math.ceil(total / PAGE_SIZE))
  const first = total === 0 ? 0 : (page - 1) * PAGE_SIZE + 1
  const last = Math.min(page * PAGE_SIZE, total)

  let list: React.ReactNode
  if (!data && error) {
    list = (
      <EmptyState icon={<CircleAlertIcon />} title="Cannot load events">
        <span className="font-data text-xs">{error}</span>
        <Button variant="outline" onClick={() => setReload((value) => value + 1)}>
          Try again
        </Button>
      </EmptyState>
    )
  } else if (!data) {
    list = <LoadingState label="Loading events" />
  } else if (data.total === 0) {
    list = (
      <EmptyState icon={<ScanEyeIcon />} title="No events">
        <span>
          {query.camera_uuid || query.kind || query.label || query.plate || query.from
            ? "Nothing matches these filters."
            : "Events appear here as soon as a camera reports motion or a problem."}
        </span>
      </EmptyState>
    )
  } else {
    list = (
      <>
        <ul aria-label="Events">
          {data.items.map((event) => (
            <EventRow key={event.uuid} event={event} selected={event.uuid === selected} onSelect={select} />
          ))}
        </ul>
        <div className="flex items-center justify-between gap-3 px-3 py-3 sm:px-4">
          <span className="font-data text-[11px] text-text-3">
            {first} to {last} of {total}
            {error ? <span className="ml-3 text-danger">{error}</span> : null}
          </span>
          <div className="flex items-center gap-1">
            <IconButton
              label="Newer"
              variant="outline"
              size="icon-sm"
              side="top"
              disabled={page <= 1}
              onClick={() => setPage((value) => Math.max(1, value - 1))}
            >
              <ChevronLeftIcon />
            </IconButton>
            <IconButton
              label="Older"
              variant="outline"
              size="icon-sm"
              side="top"
              disabled={page >= pageCount}
              onClick={() => setPage((value) => Math.min(pageCount, value + 1))}
            >
              <ChevronRightIcon />
            </IconButton>
          </div>
        </div>
      </>
    )
  }

  return (
    <PageFrame
      status={
        <Chip>
          <span
            aria-hidden
            className={cn("inline-block size-2 rounded-full", connected ? "bg-status-ok" : "bg-status-warn")}
          />
          {connected ? "Live" : "Reconnecting"}
        </Chip>
      }
      toolbar={
        <Filters
          camera={camera}
          kind={kind}
          label={label}
          plate={plate}
          day={day}
          onCamera={changeFilter(setCamera)}
          onKind={changeFilter(setKind)}
          onLabel={changeFilter(setLabel)}
          onPlate={setPlate}
          onDay={changeFilter(setDay)}
          onClear={clear}
        />
      }
    >
      <div className="flex min-h-0 min-w-0 flex-1">
        <main className="flex min-h-0 min-w-0 flex-1 flex-col overflow-y-auto">
          <div className="flex flex-col gap-3 border-b border-hairline px-3 py-3 sm:px-4">
            <EventCountRow query={query} />
            {sources.length > 0 ? (
              <div aria-label="Event sources" className="flex flex-wrap gap-1.5">
                {sources.map((source) => (
                  <SourceChip key={source.camera_uuid} source={source} />
                ))}
              </div>
            ) : null}
          </div>
          <div className="min-h-0 flex-1">{list}</div>
        </main>
        {selectedEvent ? (
          <aside
            aria-label="Event details"
            className="fixed inset-x-0 top-[58px] bottom-0 z-30 overflow-y-auto bg-surface lg:static lg:z-auto lg:w-[360px] lg:shrink-0 lg:border-l lg:border-hairline"
          >
            <EventPanel event={selectedEvent} onClose={() => setSelected(null)} onOpenEvent={setSelected} />
          </aside>
        ) : null}
      </div>
    </PageFrame>
  )
}

/** The Events page: the live list of camera events with filters and a detail panel. */
export function EventsPage() {
  return (
    <React.Suspense
      fallback={
        <PageFrame>
          <main className="min-w-0 flex-1">
            <LoadingState label="Loading events" />
          </main>
        </PageFrame>
      }
    >
      <EventsView />
    </React.Suspense>
  )
}
