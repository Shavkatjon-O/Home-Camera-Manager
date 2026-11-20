"use client"

import * as React from "react"

import { BoxLayer, type DrawnBox } from "@/components/analytics/box-layer"
import { api, isAbort } from "@/lib/api"
import { labelName } from "@/lib/events"
import type { LiveObject } from "@/lib/types"

const LIVE_MS = 250
const MIN_GAP_MS = 50
const RETRY_MS = 1000
const HIDDEN_MS = 1000

function drawn(objects: LiveObject[]): DrawnBox[] {
  return objects.map((item) => ({
    key: String(item.track),
    box: item.box,
    label: item.label,
    caption: `${labelName(item.label)} ${item.track}`,
  }))
}

export function LiveObjects({ viewUuid }: { viewUuid: string }) {
  const [objects, setObjects] = React.useState<LiveObject[]>([])

  React.useEffect(() => {
    let disposed = false
    let timer = 0
    let controller: AbortController | null = null

    const tick = async () => {
      let wait = HIDDEN_MS
      if (document.visibilityState === "visible") {
        controller = new AbortController()
        const started = performance.now()
        try {
          const data = await api.analyticsObjects(viewUuid, controller.signal)
          if (disposed) return
          setObjects(data.at === null ? [] : data.objects)
          wait = Math.max(MIN_GAP_MS, LIVE_MS - (performance.now() - started))
        } catch (err) {
          if (disposed || isAbort(err)) return
          setObjects([])
          wait = RETRY_MS
        }
      }
      if (!disposed) timer = window.setTimeout(tick, wait)
    }

    void tick()
    return () => {
      disposed = true
      window.clearTimeout(timer)
      controller?.abort()
    }
  }, [viewUuid])

  return <BoxLayer boxes={drawn(objects)} />
}
