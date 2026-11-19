"use client"

import * as React from "react"
import Link from "next/link"

import { EventDuration, EventThumb, KindChip } from "@/components/events/event-parts"
import { useCameraSource, useEvents } from "@/components/events/events-provider"
import { sourceSummary } from "@/components/events/source-chip"
import { Spinner } from "@/components/shell/primitives"
import { api, isAbort } from "@/lib/api"
import { SOURCE_LABELS, SOURCE_TONES } from "@/lib/events"
import { formatMoment } from "@/lib/health"
import { useClockSeconds } from "@/lib/stores"
import type { CameraEvent } from "@/lib/types"
import { cn } from "@/lib/utils"

const RECENT = 6

function eventHref(event: CameraEvent): string {
  return `/events/?camera=${encodeURIComponent(event.camera_uuid)}&event=${encodeURIComponent(event.uuid)}`
}

export function CameraEvents({ cameraUuid }: { cameraUuid: string }) {
  const { version, subscribe } = useEvents()
  const source = useCameraSource(cameraUuid)
  const seconds = useClockSeconds()
  const [events, setEvents] = React.useState<CameraEvent[] | null>(null)
  const [failed, setFailed] = React.useState(false)

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .listEvents({ camera_uuid: cameraUuid, page_size: RECENT }, controller.signal)
      .then((page) => {
        setEvents(page.items)
        setFailed(false)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setFailed(true)
      })
    return () => controller.abort()
  }, [cameraUuid, version])

  React.useEffect(
    () =>
      subscribe((event) => {
        if (event.camera_uuid !== cameraUuid) return
        setEvents((current) => {
          if (!current) return current
          const index = current.findIndex((item) => item.uuid === event.uuid)
          if (index >= 0) {
            const next = [...current]
            next[index] = event
            return next
          }
          return [event, ...current].slice(0, RECENT)
        })
      }),
    [subscribe, cameraUuid],
  )

  return (
    <div className="flex flex-col gap-3">
      {source ? (
        <div className="flex flex-col gap-1">
          <div className="flex items-center gap-2 text-[12px] text-foreground">
            <span aria-hidden className={cn("inline-block size-2 rounded-full", SOURCE_TONES[source.state])} />
            {source.state === "unsupported" ? "Events not available from this camera" : SOURCE_LABELS[source.state]}
          </div>
          <span className="text-[12px] text-text-3">{sourceSummary(source, seconds * 1000)}</span>
        </div>
      ) : null}
      {events === null ? (
        failed ? (
          <span className="text-[12px] text-text-3">Cannot load events.</span>
        ) : (
          <Spinner />
        )
      ) : events.length === 0 ? (
        <span className="text-[12px] text-text-3">No events yet.</span>
      ) : (
        <ul className="flex flex-col">
          {events.map((event) => (
            <li key={event.uuid}>
              <Link
                href={eventHref(event)}
                className="flex items-center gap-2.5 rounded-md py-1.5 transition-colors hover:bg-surface-2"
              >
                <EventThumb event={event} className="w-16" />
                <div className="flex min-w-0 flex-1 flex-col gap-0.5">
                  <KindChip event={event} className="self-start" />
                  <span className="truncate font-data text-[11px] text-text-2">{formatMoment(event.started_at)}</span>
                </div>
                <EventDuration event={event} />
              </Link>
            </li>
          ))}
        </ul>
      )}
      <Link href={`/events/?camera=${encodeURIComponent(cameraUuid)}`} className="text-[12px] text-text-2 hover:text-foreground">
        All events of this camera
      </Link>
    </div>
  )
}
