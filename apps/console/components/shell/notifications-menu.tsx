"use client"

import * as React from "react"
import Link from "next/link"
import { BellIcon, BellOffIcon } from "lucide-react"

import { Spinner } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Switch } from "@/components/ui/switch"
import { api, errorMessage, isAbort } from "@/lib/api"
import { eventTitle, setAlertsMuted, useAlertsMuted, useUnseenAlerts } from "@/lib/events"
import { formatMoment } from "@/lib/health"
import type { CameraEvent } from "@/lib/types"
import { cn } from "@/lib/utils"

const RECENT = 6
const BADGE_MAX = 99

function eventHref(uuid: string): string {
  return `/events/?event=${encodeURIComponent(uuid)}`
}

/**
 * The notifications bell of the top bar: a badge with the alerts not yet seen on the Events page, and a popover
 * with the latest events, the switch for pop-up alerts and a link to every event.
 */
export function NotificationsMenu() {
  const unseen = useUnseenAlerts()
  const muted = useAlertsMuted()
  const [open, setOpen] = React.useState(false)
  const [recent, setRecent] = React.useState<CameraEvent[] | null>(null)
  const [error, setError] = React.useState<string | null>(null)

  React.useEffect(() => {
    if (!open) return
    const controller = new AbortController()
    api
      .listEvents({ page_size: RECENT }, controller.signal)
      .then((page) => {
        setRecent(page.items)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(errorMessage(err))
      })
    return () => controller.abort()
  }, [open])

  const label = unseen > 0 ? `Notifications, ${unseen} new ${unseen === 1 ? "alert" : "alerts"}` : "Notifications"
  const close = () => setOpen(false)

  let list: React.ReactNode
  if (!recent && error) {
    list = <p className="px-3 py-6 text-center text-[12px] text-danger">{error}</p>
  } else if (!recent) {
    list = (
      <div className="flex items-center justify-center gap-2 px-3 py-6 text-[12px] text-text-3">
        <Spinner className="size-3.5" />
        Loading events
      </div>
    )
  } else if (recent.length === 0) {
    list = (
      <p className="px-3 py-6 text-center text-[12px] text-text-3">
        No events yet. They appear here as soon as a camera reports one.
      </p>
    )
  } else {
    list = (
      <ul aria-label="Latest events" className="flex flex-col p-1">
        {recent.map((event) => (
          <li key={event.uuid}>
            <Link
              href={eventHref(event.uuid)}
              onClick={close}
              className="flex items-start gap-2.5 rounded-md px-2 py-2 outline-none transition-colors hover:bg-surface-2 focus-visible:bg-surface-2"
            >
              <span className="flex h-[18px] items-center">
                <span
                  aria-hidden
                  className={cn("inline-block size-2 rounded-full", event.alert ? "bg-status-err" : "bg-status-off")}
                />
              </span>
              <span className="flex min-w-0 flex-1 flex-col gap-0.5">
                <span className="truncate text-[13px] text-foreground">{eventTitle(event)}</span>
                <span className="font-data text-[11px] text-text-3">
                  {formatMoment(event.started_at)}
                  {event.alert ? " - alert" : null}
                </span>
              </span>
            </Link>
          </li>
        ))}
      </ul>
    )
  }

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button variant="ghost" size="icon" aria-label={label} className="relative">
          {muted ? <BellOffIcon className="size-4" /> : <BellIcon className="size-4" />}
          {unseen > 0 ? (
            <span
              aria-hidden
              className="absolute top-0.5 right-0.5 inline-flex h-4 min-w-4 items-center justify-center rounded-full bg-status-err px-1 font-data text-[10px] leading-none text-white"
            >
              {unseen > BADGE_MAX ? `${BADGE_MAX}+` : unseen}
            </span>
          ) : null}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-80" aria-label="Notifications">
        <div className="flex items-center justify-between gap-3 border-b border-hairline px-3 py-2.5">
          <span className="text-[13px] font-medium text-foreground">Notifications</span>
          <span className="font-data text-[11px] text-text-3">
            {unseen > 0 ? `${unseen} new ${unseen === 1 ? "alert" : "alerts"}` : "No new alerts"}
          </span>
        </div>
        {list}
        <div className="flex items-center justify-between gap-3 border-t border-hairline px-3 py-2.5">
          <label className="flex items-center gap-2 text-[12px] text-text-2">
            <Switch checked={!muted} onCheckedChange={(checked) => setAlertsMuted(!checked)} />
            Pop-up alerts
          </label>
          <Button asChild variant="ghost" size="sm">
            <Link href="/events/" onClick={close}>
              All events
            </Link>
          </Button>
        </div>
      </PopoverContent>
    </Popover>
  )
}
