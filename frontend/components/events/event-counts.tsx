"use client"

import * as React from "react"

import { useEvents } from "@/components/events/events-provider"
import { Chip } from "@/components/shell/primitives"
import { api } from "@/lib/api"
import { EVENT_KINDS, EVENT_LABELS, KIND_LABELS, labelName } from "@/lib/events"
import type { EventCountQuery, EventCounts, EventKind } from "@/lib/types"
import { cn } from "@/lib/utils"

const REFRESH_MS = 1500

function present(values: Record<string, number>, order: string[]): string[] {
  return Object.keys(values)
    .filter((key) => values[key] > 0)
    .sort((a, b) => {
      const left = order.indexOf(a)
      const right = order.indexOf(b)
      if (left !== right) return (left < 0 ? order.length : left) - (right < 0 ? order.length : right)
      return a.localeCompare(b)
    })
}

function kindName(kind: string): string {
  return KIND_LABELS[kind as EventKind] ?? labelName(kind)
}

function Group({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div role="group" aria-label={label} className="flex flex-wrap items-center gap-1.5">
      <span className="text-[11px] text-text-3">{label}</span>
      {children}
    </div>
  )
}

function Count({ name, value }: { name: string; value: number }) {
  return (
    <Chip>
      {name}
      <span className="text-foreground">{value}</span>
    </Chip>
  )
}

export function EventCountRow({ query }: { query: EventCountQuery }) {
  const { version, subscribe } = useEvents()
  const [counts, setCounts] = React.useState<EventCounts | null>(null)
  const [tick, setTick] = React.useState(0)

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .eventCounts(query, controller.signal)
      .then(setCounts)
      .catch(() => undefined)
    return () => controller.abort()
  }, [query, version, tick])

  React.useEffect(() => {
    let timer = 0
    const unsubscribe = subscribe(() => {
      if (timer) return
      timer = window.setTimeout(() => {
        timer = 0
        setTick((value) => value + 1)
      }, REFRESH_MS)
    })
    return () => {
      unsubscribe()
      window.clearTimeout(timer)
    }
  }, [subscribe])

  if (!counts) return null
  const kinds = present(counts.kinds, EVENT_KINDS)
  const labels = present(counts.labels, EVENT_LABELS)

  return (
    <div aria-label="Event counts" className="flex flex-wrap items-center gap-x-3 gap-y-1.5">
      <div className="flex flex-wrap items-center gap-1.5">
        <Chip>
          <span className="text-foreground">{counts.total}</span>
          {counts.total === 1 ? "event" : "events"}
        </Chip>
        <Chip className={cn(counts.alerts > 0 && "bg-status-err/15 text-status-err")}>
          Alerts
          <span className={counts.alerts > 0 ? undefined : "text-foreground"}>{counts.alerts}</span>
        </Chip>
      </div>
      {kinds.length > 0 ? (
        <Group label="Kinds">
          {kinds.map((kind) => (
            <Count key={kind} name={kindName(kind)} value={counts.kinds[kind]} />
          ))}
        </Group>
      ) : null}
      {labels.length > 0 ? (
        <Group label="Labels">
          {labels.map((label) => (
            <Count key={label} name={labelName(label)} value={counts.labels[label]} />
          ))}
        </Group>
      ) : null}
    </div>
  )
}
