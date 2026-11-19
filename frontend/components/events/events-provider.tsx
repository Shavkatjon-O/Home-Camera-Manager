"use client"

import * as React from "react"
import { useRouter } from "next/navigation"
import { toast } from "sonner"

import { EVENT_STREAM_URL, api } from "@/lib/api"
import { eventTitle, useAlertsMuted } from "@/lib/events"
import { formatTime } from "@/lib/format"
import type { CameraEvent, CameraEventSource, EventStreamHello } from "@/lib/types"

const RECONNECT_MS = 5000
const FRESH_MS = 60000
const SEEN_LIMIT = 2000

type Listener = (event: CameraEvent) => void

interface EventsValue {
  connected: boolean
  version: number
  sources: CameraEventSource[]
  open: CameraEvent[]
  subscribe: (listener: Listener) => () => void
}

const EventsContext = React.createContext<EventsValue | null>(null)

export function useEvents(): EventsValue {
  const value = React.useContext(EventsContext)
  if (!value) throw new Error("useEvents needs an EventsProvider")
  return value
}

export function useCameraSource(cameraUuid: string): CameraEventSource | null {
  const { sources } = useEvents()
  return sources.find((source) => source.camera_uuid === cameraUuid) ?? null
}

export function useOpenEvents(cameraUuid: string): CameraEvent[] {
  const { open } = useEvents()
  return React.useMemo(() => open.filter((event) => event.camera_uuid === cameraUuid), [open, cameraUuid])
}

function parse<T>(message: MessageEvent): T | null {
  try {
    return JSON.parse(message.data) as T
  } catch {
    return null
  }
}

export function EventsProvider({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const muted = useAlertsMuted()
  const mutedRef = React.useRef(muted)
  const listeners = React.useRef(new Set<Listener>())
  const seen = React.useRef(new Set<string>())
  const [connected, setConnected] = React.useState(false)
  const [version, setVersion] = React.useState(0)
  const [sources, setSources] = React.useState<CameraEventSource[]>([])
  const [openMap, setOpenMap] = React.useState<Record<string, CameraEvent>>({})

  React.useEffect(() => {
    mutedRef.current = muted
  }, [muted])

  const announce = React.useEffectEvent((event: CameraEvent) => {
    if (mutedRef.current) return
    if (Date.now() - Date.parse(event.created_at) > FRESH_MS) return
    toast(eventTitle(event), {
      id: event.uuid,
      description: `Started ${formatTime(event.started_at)}`,
      action: { label: "View", onClick: () => router.push(`/events/?event=${encodeURIComponent(event.uuid)}`) },
    })
  })

  React.useEffect(() => {
    let source: EventSource | null = null
    let timer = 0
    let disposed = false

    const remember = (uuid: string): boolean => {
      if (seen.current.has(uuid)) return false
      if (seen.current.size > SEEN_LIMIT) seen.current.clear()
      seen.current.add(uuid)
      return true
    }

    const connect = () => {
      if (disposed) return
      const stream = new EventSource(EVENT_STREAM_URL)
      source = stream
      stream.addEventListener("hello", (message) => {
        const hello = parse<EventStreamHello>(message)
        if (!hello) return
        hello.open.forEach((event) => remember(event.uuid))
        setSources(hello.sources)
        setOpenMap(Object.fromEntries(hello.open.map((event) => [event.uuid, event])))
        setConnected(true)
        setVersion((value) => value + 1)
      })
      stream.addEventListener("event", (message) => {
        const event = parse<CameraEvent>(message)
        if (!event) return
        const fresh = remember(event.uuid)
        setOpenMap((current) => {
          if (!event.ongoing && !(event.uuid in current)) return current
          const next = { ...current }
          if (event.ongoing) next[event.uuid] = event
          else delete next[event.uuid]
          return next
        })
        listeners.current.forEach((listener) => listener(event))
        if (fresh) announce(event)
      })
      stream.addEventListener("source", (message) => {
        const update = parse<CameraEventSource>(message)
        if (!update) return
        setSources((current) => {
          const index = current.findIndex((item) => item.camera_uuid === update.camera_uuid)
          if (index < 0) return [...current, update]
          const next = [...current]
          next[index] = update
          return next
        })
      })
      stream.addEventListener("source_removed", (message) => {
        const removed = parse<{ camera_uuid: string }>(message)
        if (!removed) return
        setSources((current) => current.filter((item) => item.camera_uuid !== removed.camera_uuid))
      })
      stream.addEventListener("overflow", () => {
        stream.close()
        connect()
      })
      stream.onerror = () => {
        setConnected(false)
        if (stream.readyState !== EventSource.CLOSED) return
        stream.close()
        window.clearTimeout(timer)
        timer = window.setTimeout(() => {
          api
            .me(true)
            .then(connect)
            .catch(() => {
              timer = window.setTimeout(connect, RECONNECT_MS)
            })
        }, RECONNECT_MS)
      }
    }

    connect()
    return () => {
      disposed = true
      window.clearTimeout(timer)
      source?.close()
    }
  }, [])

  const subscribe = React.useCallback((listener: Listener) => {
    listeners.current.add(listener)
    return () => {
      listeners.current.delete(listener)
    }
  }, [])

  const open = React.useMemo(
    () => Object.values(openMap).sort((a, b) => Date.parse(b.started_at) - Date.parse(a.started_at)),
    [openMap],
  )

  const value = React.useMemo<EventsValue>(
    () => ({ connected, version, sources, open, subscribe }),
    [connected, version, sources, open, subscribe],
  )

  return <EventsContext.Provider value={value}>{children}</EventsContext.Provider>
}
