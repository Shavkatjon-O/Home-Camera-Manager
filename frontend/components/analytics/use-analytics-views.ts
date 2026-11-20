"use client"

import * as React from "react"

import { api, errorMessage, isAbort } from "@/lib/api"
import type { AnalyticsView } from "@/lib/types"

const POLL_MS = 5000

function byLens(views: AnalyticsView[]): AnalyticsView[] {
  return [...views].sort((a, b) => a.lens - b.lens)
}

export function useAnalyticsViews(cameraUuid: string) {
  const [views, setViews] = React.useState<AnalyticsView[] | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const changes = React.useRef(0)

  React.useEffect(() => {
    const controller = new AbortController()
    let timer = 0
    const load = async () => {
      if (document.visibilityState === "visible") {
        const started = changes.current
        try {
          const list = await api.analyticsViews(cameraUuid, controller.signal)
          if (changes.current === started) {
            setViews(byLens(list.items.filter((view) => view.camera_uuid === cameraUuid)))
            setError(null)
          }
        } catch (err) {
          if (isAbort(err)) return
          setError(errorMessage(err))
        }
      }
      if (!controller.signal.aborted) timer = window.setTimeout(load, POLL_MS)
    }
    void load()
    return () => {
      controller.abort()
      window.clearTimeout(timer)
    }
  }, [cameraUuid])

  const replace = React.useCallback((view: AnalyticsView) => {
    changes.current += 1
    setViews((current) => {
      if (!current) return [view]
      const index = current.findIndex((item) => item.uuid === view.uuid)
      if (index < 0) return byLens([...current, view])
      const next = [...current]
      next[index] = view
      return next
    })
  }, [])

  return { views, error, replace }
}
