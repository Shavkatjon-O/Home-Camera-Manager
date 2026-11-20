"use client"

import * as React from "react"

import { Chip } from "@/components/shell/primitives"
import { isAbort } from "@/lib/api"
import { fetchEventJourney, type Journey } from "@/lib/extras"
import { formatTime } from "@/lib/format"

interface Loaded {
  uuid: string
  journey: Journey | null
}

export function EventJourney({
  eventUuid,
  onOpenEvent,
}: {
  eventUuid: string
  onOpenEvent: (eventUuid: string) => void
}) {
  const [loaded, setLoaded] = React.useState<Loaded | null>(null)

  React.useEffect(() => {
    const controller = new AbortController()
    fetchEventJourney(eventUuid, controller.signal)
      .then((journey) => setLoaded({ uuid: eventUuid, journey }))
      .catch((error: unknown) => {
        if (isAbort(error)) return
        setLoaded({ uuid: eventUuid, journey: null })
      })
    return () => controller.abort()
  }, [eventUuid])

  const waiting = loaded === null || loaded.uuid !== eventUuid
  const journey = waiting ? null : loaded.journey

  if (waiting) {
    return (
      <section className="flex flex-col gap-3 border-b border-hairline px-4 py-4 last:border-b-0">
        <p className="text-[12px] text-text-3">Looking for the journey.</p>
      </section>
    )
  }
  if (!journey) return null

  return (
    <section className="flex flex-col gap-3 border-b border-hairline px-4 py-4 last:border-b-0">
      <div className="flex items-center gap-2">
        <h2 className="text-xs text-text-3">Journey</h2>
        <Chip className="h-5 px-1.5 text-[10px]">Beta</Chip>
      </div>
      <p className="text-[13px] text-foreground">{journey.description}</p>
      <ol className="flex flex-col gap-1">
        {journey.steps.map((step, index) => {
          const content = (
            <>
              <span className="min-w-0 flex-1 truncate text-[13px] text-foreground">
                {step.view_name}
                <span className="text-text-3"> {step.camera_name}</span>
              </span>
              <span className="shrink-0 font-data text-[12px] text-text-2">{formatTime(step.started_at)}</span>
            </>
          )
          return (
            <li key={`${step.view_uuid}-${step.started_at}-${index}`}>
              {step.event_uuid ? (
                <button
                  type="button"
                  onClick={() => onOpenEvent(step.event_uuid as string)}
                  className="flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left transition-colors hover:bg-surface-2"
                >
                  {content}
                </button>
              ) : (
                <div className="flex w-full items-center gap-2 px-2 py-1.5">{content}</div>
              )}
            </li>
          )
        })}
      </ol>
    </section>
  )
}
