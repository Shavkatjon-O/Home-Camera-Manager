"use client"

import * as React from "react"
import Link from "next/link"
import { ActivityIcon, CctvIcon, CircleAlertIcon, PlusIcon, RouterIcon } from "lucide-react"

import { DeviceFormDialog } from "@/components/health/device-form-dialog"
import { OUTAGE_PAGE_SIZE, OutageLog } from "@/components/health/outage-log"
import { TargetCard } from "@/components/health/target-card"
import { TargetPanel } from "@/components/health/target-panel"
import { CardGrid, PageContent, PageFrame } from "@/components/shell/page-frame"
import { Chip, EmptyState, LoadingState } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
import { useCan } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import { api, errorMessage, isAbort } from "@/lib/api"
import { RANGE_OPTIONS, RANGE_OPTIONS_SHORT, TONE_CLASSES, formatSpan, isHealthy, type Tone } from "@/lib/health"
import type { HealthOverview, HealthRange, Outage, Page, TargetDetail, TargetHealth } from "@/lib/types"
import { cn } from "@/lib/utils"

const REFRESH_MS = 15000
const TARGET_OUTAGES = 20

function editableTarget(target: EventTarget | null): boolean {
  if (!(target instanceof Element)) return false
  return Boolean(target.closest("input, textarea, select, [role='dialog'], [role='alertdialog'], [role='listbox']"))
}

function HealthyChip({ targets }: { targets: TargetHealth[] }) {
  const enabled = targets.filter((target) => target.enabled)
  if (enabled.length === 0) return null
  const healthy = enabled.filter(isHealthy).length
  const down = enabled.some((target) => target.status === "down")
  const tone: Tone = healthy === enabled.length ? "ok" : down ? "err" : "warn"
  return (
    <Chip data-testid="healthy-chip">
      <span aria-hidden className={cn("inline-block size-2 rounded-full", TONE_CLASSES[tone])} />
      {healthy} of {enabled.length} healthy
    </Chip>
  )
}

function Group({ title, count, children }: { title: string; count: number; children: React.ReactNode }) {
  return (
    <section className="flex flex-col gap-2">
      <div className="flex items-baseline gap-2">
        <h2 className="text-xs text-text-3">{title}</h2>
        <span className="font-data text-[11px] text-text-3">{count}</span>
      </div>
      {count > 0 ? <CardGrid>{children}</CardGrid> : children}
    </section>
  )
}

function GroupEmpty({ icon, children }: { icon: React.ReactNode; children: React.ReactNode }) {
  return (
    <div className="flex items-start gap-3 rounded-lg border border-hairline bg-surface p-4">
      <div className="mt-0.5 text-text-3 [&_svg]:size-4">{icon}</div>
      <div className="flex min-w-0 flex-col items-start gap-3 text-[13px] text-text-3">{children}</div>
    </div>
  )
}

/** The Health page: reachability and latency of cameras and network devices, and the outage log. */
export function HealthView() {
  const canManage = useCan("admin")
  const [range, setRange] = React.useState<HealthRange>("1h")
  const [tick, setTick] = React.useState(0)
  const [reload, setReload] = React.useState(0)
  const [overview, setOverview] = React.useState<HealthOverview | null>(null)
  const [overviewError, setOverviewError] = React.useState<string | null>(null)
  const [selected, setSelected] = React.useState<string | null>(null)
  const [detail, setDetail] = React.useState<TargetDetail | null>(null)
  const [targetOutages, setTargetOutages] = React.useState<{ uuid: string; items: Outage[] } | null>(null)
  const [outagePage, setOutagePage] = React.useState(1)
  const [outages, setOutages] = React.useState<Page<Outage> | null>(null)
  const [outagesError, setOutagesError] = React.useState<string | null>(null)
  const [formOpen, setFormOpen] = React.useState(false)
  const [editing, setEditing] = React.useState<TargetHealth | null>(null)

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

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .healthOverview(range, controller.signal)
      .then((data) => {
        setOverview(data)
        setOverviewError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setOverviewError(errorMessage(err))
      })
    return () => controller.abort()
  }, [range, tick, reload])

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .listOutages({ page: outagePage, page_size: OUTAGE_PAGE_SIZE }, controller.signal)
      .then((data) => {
        if (data.items.length === 0 && data.total > 0 && outagePage > 1) {
          setOutagePage(Math.max(1, Math.ceil(data.total / OUTAGE_PAGE_SIZE)))
          return
        }
        setOutages(data)
        setOutagesError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setOutagesError(errorMessage(err))
      })
    return () => controller.abort()
  }, [outagePage, tick, reload])

  React.useEffect(() => {
    if (!selected) return
    const controller = new AbortController()
    api
      .healthTarget(selected, range, controller.signal)
      .then(setDetail)
      .catch(() => undefined)
    api
      .listOutages({ target_uuid: selected, page_size: TARGET_OUTAGES }, controller.signal)
      .then((data) => setTargetOutages({ uuid: selected, items: data.items }))
      .catch(() => undefined)
    return () => controller.abort()
  }, [selected, range, tick, reload])

  const targets = React.useMemo(() => overview?.targets ?? [], [overview])
  const devices = targets.filter((target) => target.kind === "device")
  const cameras = targets.filter((target) => target.kind === "camera")
  const selectedTarget = selected ? (targets.find((target) => target.uuid === selected) ?? null) : null
  const shownRange = overview?.range ?? range
  const now = overview ? Date.parse(overview.until) : 0

  const select = (uuid: string) => {
    if (!targets.some((target) => target.uuid === uuid)) return
    setSelected((current) => (current === uuid ? null : uuid))
  }

  const changed = () => setReload((value) => value + 1)

  const openAdd = () => {
    setEditing(null)
    setFormOpen(true)
  }

  const onKeyDown = React.useEffectEvent((event: KeyboardEvent) => {
    if (event.key !== "Escape" || editableTarget(event.target) || formOpen) return
    setSelected(null)
  })

  React.useEffect(() => {
    const listener = (event: KeyboardEvent) => onKeyDown(event)
    window.addEventListener("keydown", listener)
    return () => window.removeEventListener("keydown", listener)
  }, [])

  const actions = (
    <>
      <Segmented<HealthRange>
        label="Range"
        value={range}
        options={RANGE_OPTIONS}
        onChange={setRange}
        className="hidden md:flex"
      />
      <Segmented<HealthRange>
        label="Range"
        value={range}
        options={RANGE_OPTIONS_SHORT}
        onChange={setRange}
        className="md:hidden"
      />
      {canManage ? (
        <Button onClick={openAdd} aria-label="Add network device">
          <PlusIcon />
          <span className="hidden sm:inline">Add network device</span>
        </Button>
      ) : null}
    </>
  )

  let content: React.ReactNode
  if (!overview && overviewError) {
    content = (
      <EmptyState icon={<CircleAlertIcon />} title="Cannot load health">
        <span className="font-data text-xs">{overviewError}</span>
        <Button variant="outline" onClick={changed}>
          Try again
        </Button>
      </EmptyState>
    )
  } else if (!overview) {
    content = <LoadingState label="Loading health" />
  } else if (targets.length === 0) {
    content = (
      <EmptyState icon={<ActivityIcon />} title="Nothing to watch yet">
        <span>Add the routers and access points the cameras connect through, then each camera shows up here too.</span>
        {canManage ? (
          <Button variant="outline" onClick={openAdd}>
            <PlusIcon />
            Add network device
          </Button>
        ) : null}
      </EmptyState>
    )
  } else {
    content = (
      <PageContent>
        <p className="font-data text-[11px] text-text-3">
          Probed every {formatSpan(overview.interval_seconds)}, bars of {formatSpan(overview.bucket_seconds)}
          {overviewError ? <span className="ml-3 text-danger">{overviewError}</span> : null}
        </p>
        <Group title="Routers" count={devices.length}>
          {devices.length > 0 ? (
            devices.map((target) => (
              <TargetCard
                key={target.uuid}
                target={target}
                range={shownRange}
                selected={target.uuid === selected}
                onSelect={select}
              />
            ))
          ) : (
            <GroupEmpty icon={<RouterIcon />}>
              <span>
                No network devices yet. Add the routers and access points the cameras connect through, so an outage
                shows where it starts.
              </span>
              {canManage ? (
                <Button variant="outline" onClick={openAdd}>
                  <PlusIcon />
                  Add network device
                </Button>
              ) : null}
            </GroupEmpty>
          )}
        </Group>
        <Group title="Cameras" count={cameras.length}>
          {cameras.length > 0 ? (
            cameras.map((target) => (
              <TargetCard
                key={target.uuid}
                target={target}
                range={shownRange}
                selected={target.uuid === selected}
                onSelect={select}
              />
            ))
          ) : (
            <GroupEmpty icon={<CctvIcon />}>
              <span>No cameras yet. Every camera registered at this site is watched here.</span>
              <Button asChild variant="outline">
                <Link href="/cameras/">Go to cameras</Link>
              </Button>
            </GroupEmpty>
          )}
        </Group>
        <OutageLog data={outages} error={outagesError} page={outagePage} onPage={setOutagePage} onSelect={select} />
      </PageContent>
    )
  }

  return (
    <PageFrame status={<HealthyChip targets={targets} />} actions={actions} contained>
      <div className="flex min-h-0 min-w-0 flex-1">
        <main className="@container min-h-0 min-w-0 flex-1 overflow-y-auto">{content}</main>
        {selectedTarget ? (
          <aside
            aria-label={`${selectedTarget.name} details`}
            className="fixed inset-x-0 top-[58px] bottom-0 z-30 overflow-y-auto bg-surface lg:static lg:z-auto lg:w-[340px] lg:shrink-0 lg:border-l lg:border-hairline"
          >
            <TargetPanel
              target={selectedTarget}
              detail={detail && detail.range === shownRange ? detail : null}
              outages={targetOutages && targetOutages.uuid === selectedTarget.uuid ? targetOutages.items : null}
              devices={devices}
              range={shownRange}
              now={now}
              onClose={() => setSelected(null)}
              onEdit={() => {
                setEditing(selectedTarget)
                setFormOpen(true)
              }}
              onChanged={changed}
              onDeleted={() => {
                setSelected(null)
                changed()
              }}
            />
          </aside>
        ) : null}
      </div>
      <DeviceFormDialog
        open={formOpen}
        onOpenChange={setFormOpen}
        device={editing}
        devices={devices}
        onSaved={changed}
      />
    </PageFrame>
  )
}
