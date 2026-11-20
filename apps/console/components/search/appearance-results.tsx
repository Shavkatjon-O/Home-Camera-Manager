"use client"

import * as React from "react"
import Link from "next/link"
import { ArrowLeftIcon, CircleAlertIcon, UserSearchIcon } from "lucide-react"

import { FindPersonButton, ResultImage } from "@/components/search/result-parts"
import type { Layout } from "@/components/search/search-params"
import { Chip, EmptyState, LoadingState } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { ApiError, errorMessage, eventImageUrl, isAbort } from "@/lib/api"
import { findSimilarAppearances, type SimilarAppearance } from "@/lib/extras"
import { formatMoment } from "@/lib/health"
import { eventHref, formatScore } from "@/lib/people"
import { cn } from "@/lib/utils"

export const APPEARANCE_LIMIT = 48

type State =
  | { key: string; status: "done"; items: SimilarAppearance[] }
  | { key: string; status: "error"; message: string; missing: boolean }

function whereOf(item: SimilarAppearance): string {
  const parts = [item.camera_name ?? "Removed camera"]
  if (item.view_name && item.view_name !== item.camera_name) parts.push(item.view_name)
  return parts.join(", ")
}

function MaybeLink({ href, className, children }: { href: string | null; className?: string; children: React.ReactNode }) {
  if (!href) return <div className={className}>{children}</div>
  return (
    <Link href={href} className={className}>
      {children}
    </Link>
  )
}

function Score({ value }: { value: number }) {
  return (
    <span className="shrink-0 font-data text-[12px] text-foreground">
      {formatScore(value)}
      <span className="ml-1 text-text-3">alike</span>
    </span>
  )
}

function AppearanceCard({
  item,
  onFindPerson,
}: {
  item: SimilarAppearance
  onFindPerson: (eventUuid: string) => void
}) {
  const event = item.event_uuid
  return (
    <li className="relative min-w-0 overflow-hidden rounded-lg border border-hairline bg-surface transition-colors hover:border-hairline-strong">
      <MaybeLink href={event ? eventHref(event) : null} className="flex flex-col">
        <ResultImage
          src={event ? eventImageUrl(event, true) : null}
          fit="cover"
          sizes="(min-width: 1024px) 25vw, 50vw"
          className="w-full rounded-none"
        />
        <div className="flex min-w-0 flex-col gap-1.5 p-2.5">
          <div className="flex min-w-0 items-center justify-between gap-2">
            <span className="truncate text-[13px] text-foreground">{whereOf(item)}</span>
            <Score value={item.similarity} />
          </div>
          <span className="font-data text-[11px] text-text-2">{formatMoment(item.started_at)}</span>
        </div>
      </MaybeLink>
      {event ? (
        <div className="absolute top-2 right-2">
          <FindPersonButton eventUuid={event} onFindPerson={onFindPerson} overlay />
        </div>
      ) : null}
    </li>
  )
}

function AppearanceRow({
  item,
  onFindPerson,
}: {
  item: SimilarAppearance
  onFindPerson: (eventUuid: string) => void
}) {
  const event = item.event_uuid
  return (
    <li className="flex items-center gap-1 border-b border-hairline pr-2 transition-colors hover:bg-surface-2 sm:pr-3">
      <MaybeLink
        href={event ? eventHref(event) : null}
        className="flex min-w-0 flex-1 items-center gap-3 px-3 py-2 sm:px-4"
      >
        <ResultImage src={event ? eventImageUrl(event, true) : null} fit="cover" sizes="160px" className="w-24 sm:w-32" />
        <div className="flex min-w-0 flex-1 flex-col gap-1">
          <div className="flex min-w-0 items-center gap-2">
            <span className="truncate text-[13px] text-foreground">{whereOf(item)}</span>
            <Score value={item.similarity} />
          </div>
          <span className="font-data text-[12px] text-text-2">{formatMoment(item.started_at)}</span>
        </div>
      </MaybeLink>
      {event ? <FindPersonButton eventUuid={event} onFindPerson={onFindPerson} /> : null}
    </li>
  )
}

export function AppearanceResults({
  eventUuid,
  layout,
  toolbar,
  onBack,
  onFindPerson,
}: {
  eventUuid: string
  layout: Layout
  toolbar?: React.ReactNode
  onBack: () => void
  onFindPerson: (eventUuid: string) => void
}) {
  const [reload, setReload] = React.useState(0)
  const [state, setState] = React.useState<State | null>(null)
  const key = `${eventUuid}-${reload}`

  React.useEffect(() => {
    const controller = new AbortController()
    findSimilarAppearances(eventUuid, { limit: APPEARANCE_LIMIT, signal: controller.signal })
      .then((result) => setState({ key, status: "done", items: result.items }))
      .catch((error: unknown) => {
        if (isAbort(error)) return
        const missing = error instanceof ApiError && error.code === "appearance_not_found"
        setState({ key, status: "error", message: errorMessage(error), missing })
      })
    return () => controller.abort()
  }, [eventUuid, key])

  const current = state && state.key === key ? state : null
  const count = current?.status === "done" ? current.items.length : 0

  let content: React.ReactNode
  if (!current) {
    content = <LoadingState label="Comparing people" />
  } else if (current.status === "error") {
    content = current.missing ? (
      <EmptyState icon={<UserSearchIcon />} title="Cannot compare this person">
        <span>This person was not seen long enough to compare.</span>
      </EmptyState>
    ) : (
      <EmptyState icon={<CircleAlertIcon />} title="Cannot find this person">
        <span className="font-data text-xs">{current.message}</span>
        <Button variant="outline" onClick={() => setReload((value) => value + 1)}>
          Try again
        </Button>
      </EmptyState>
    )
  } else if (current.items.length === 0) {
    content = (
      <EmptyState icon={<UserSearchIcon />} title="No one who looks alike">
        <span>No one on the other cameras looks like this person in the 7 days around the event.</span>
      </EmptyState>
    )
  } else if (layout === "grid") {
    content = (
      <ul
        aria-label="People who look alike"
        className="grid grid-cols-2 gap-3 p-3 sm:p-4 @2xl:grid-cols-3 @4xl:grid-cols-4 @6xl:grid-cols-5"
      >
        {current.items.map((item) => (
          <AppearanceCard key={item.uuid} item={item} onFindPerson={onFindPerson} />
        ))}
      </ul>
    )
  } else {
    content = (
      <ul aria-label="People who look alike">
        {current.items.map((item) => (
          <AppearanceRow key={item.uuid} item={item} onFindPerson={onFindPerson} />
        ))}
      </ul>
    )
  }

  return (
    <div className="flex min-h-full flex-col">
      <div className="flex flex-wrap items-center gap-3 border-b border-hairline px-3 py-3 sm:px-4">
        <Button variant="ghost" size="sm" onClick={onBack}>
          <ArrowLeftIcon />
          Back to results
        </Button>
        <Link href={eventHref(eventUuid)} aria-label="Open the event searched for" className="shrink-0">
          <ResultImage src={eventImageUrl(eventUuid, true)} fit="cover" sizes="72px" className="w-[72px]" />
        </Link>
        <div className="flex min-w-0 flex-col gap-0.5">
          <span className="flex items-center gap-2 text-[13px] text-foreground">
            People who look like this person
            <Chip className="h-5 px-1.5 text-[10px]">Beta</Chip>
          </span>
          <span className={cn("font-data text-[11px] text-text-3", !current && "invisible")}>
            {count === 1 ? "1 sighting" : `${count} sightings`}
          </span>
        </div>
        <div className="ml-auto flex items-center gap-2">{toolbar}</div>
        <p className="basis-full text-[12px] text-text-3">
          Matches between daylight and infrared night pictures are unreliable.
        </p>
      </div>
      <div className="min-h-0 flex-1">{content}</div>
    </div>
  )
}
