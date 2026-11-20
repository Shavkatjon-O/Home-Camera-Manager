"use client"

import * as React from "react"
import Image from "next/image"
import { ImageOffIcon, UserSearchIcon } from "lucide-react"

import { Chip, Spinner } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { ApiError, errorMessage, eventImageUrl, isAbort } from "@/lib/api"
import { findSimilarAppearances, type SimilarAppearance } from "@/lib/extras"
import { formatDateTime } from "@/lib/format"

type State =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "done"; items: SimilarAppearance[] }
  | { status: "error"; message: string }

function Card({ item, onOpen }: { item: SimilarAppearance; onOpen: (eventUuid: string) => void }) {
  const [failed, setFailed] = React.useState(false)
  const eventUuid = item.event_uuid
  const body = (
    <>
      <div className="relative aspect-video overflow-hidden rounded-md bg-surface-2">
        {eventUuid && !failed ? (
          <Image
            src={eventImageUrl(eventUuid, true)}
            alt=""
            fill
            sizes="160px"
            className="object-cover"
            onError={() => setFailed(true)}
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center text-text-3 [&_svg]:size-4">
            <ImageOffIcon aria-hidden />
          </div>
        )}
      </div>
      <div className="flex items-baseline justify-between gap-2">
        <span className="min-w-0 truncate text-[12px] text-foreground">{item.camera_name}</span>
        <span className="shrink-0 font-data text-[12px] text-text-2">{Math.round(item.similarity * 100)}%</span>
      </div>
      <span className="truncate text-[11px] text-text-3">{item.view_name}</span>
      <span className="font-data text-[11px] text-text-3">{formatDateTime(item.started_at)}</span>
    </>
  )
  if (!eventUuid) return <div className="flex min-w-0 flex-col gap-1 rounded-md p-1">{body}</div>
  return (
    <button
      type="button"
      onClick={() => onOpen(eventUuid)}
      className="flex min-w-0 flex-col gap-1 rounded-md p-1 text-left transition-colors hover:bg-surface-2"
    >
      {body}
    </button>
  )
}

export function FindPerson({
  eventUuid,
  onOpenEvent,
}: {
  eventUuid: string
  onOpenEvent: (eventUuid: string) => void
}) {
  const [stored, setStored] = React.useState<{ uuid: string; state: State } | null>(null)
  const controllerRef = React.useRef<AbortController | null>(null)
  const state: State = stored && stored.uuid === eventUuid ? stored.state : { status: "idle" }
  const setState = (next: State) => setStored({ uuid: eventUuid, state: next })

  React.useEffect(() => () => controllerRef.current?.abort(), [eventUuid])

  const search = () => {
    controllerRef.current?.abort()
    const controller = new AbortController()
    controllerRef.current = controller
    setState({ status: "loading" })
    findSimilarAppearances(eventUuid, { signal: controller.signal })
      .then((result) => setState({ status: "done", items: result.items }))
      .catch((error: unknown) => {
        if (isAbort(error)) return
        const message =
          error instanceof ApiError && error.code === "appearance_not_found"
            ? "This person was not seen long enough to compare."
            : errorMessage(error)
        setState({ status: "error", message })
      })
  }

  return (
    <section className="flex flex-col gap-3 border-b border-hairline px-4 py-4 last:border-b-0">
      <div className="flex items-center gap-2">
        <h2 className="text-xs text-text-3">Find this person</h2>
        <Chip className="h-5 px-1.5 text-[10px]">Beta</Chip>
      </div>
      <Button variant="outline" size="sm" className="self-start" disabled={state.status === "loading"} onClick={search}>
        {state.status === "loading" ? <Spinner /> : <UserSearchIcon />}
        Find this person on other cameras
      </Button>
      <p className="text-[12px] text-text-3">Beta: matches between daylight and infrared night pictures are unreliable.</p>
      {state.status === "error" ? <p className="text-[12px] text-danger">{state.message}</p> : null}
      {state.status === "done" && state.items.length === 0 ? (
        <p className="text-[12px] text-text-3">No one who looks alike in the 7 days around this event.</p>
      ) : null}
      {state.status === "done" && state.items.length > 0 ? (
        <div className="grid grid-cols-2 gap-2">
          {state.items.map((item) => (
            <Card key={item.uuid} item={item} onOpen={onOpenEvent} />
          ))}
        </div>
      ) : null}
    </section>
  )
}
