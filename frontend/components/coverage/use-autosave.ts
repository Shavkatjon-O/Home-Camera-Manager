"use client"

import * as React from "react"
import { toast } from "sonner"

import { ApiError, api, errorMessage } from "@/lib/api"
import { changedFields, pickFields, updatePayload, type PlanDoc } from "@/lib/plan-edit"
import type { FloorPlan } from "@/lib/types"

export type SaveState = "saved" | "saving" | "failed"

const SAVE_DELAY_MS = 800
const RETRY_DELAY_MS = 5000
const KEEPALIVE_MAX_CHARS = 60000

interface Failure {
  doc: PlanDoc
  message: string
  retry: boolean
}

export function useAutosave({
  uuid,
  initial,
  doc,
  paused,
  onSaved,
}: {
  uuid: string
  initial: PlanDoc
  doc: PlanDoc
  paused: boolean
  onSaved: (plan: FloorPlan) => void
}): SaveState {
  const [saved, setSaved] = React.useState(initial)
  const [inFlight, setInFlight] = React.useState(false)
  const [failure, setFailure] = React.useState<Failure | null>(null)
  const lastError = React.useRef<string | null>(null)
  const fields = React.useMemo(() => changedFields(doc, saved), [doc, saved])

  const save = React.useEffectEvent(() => {
    const current = doc
    const sent = changedFields(current, saved)
    if (sent.length === 0) return
    setInFlight(true)
    api
      .updateFloorPlan(uuid, updatePayload(current, sent))
      .then((plan) => {
        lastError.current = null
        setSaved((previous) => ({ ...previous, ...pickFields(current, sent) }))
        setFailure(null)
        onSaved(plan)
      })
      .catch((err: unknown) => {
        const message = errorMessage(err)
        const retry = !(err instanceof ApiError) || err.status === 0 || err.status >= 500
        if (lastError.current !== message) toast.error(`Save failed: ${message}`)
        lastError.current = message
        setFailure({ doc: current, message, retry })
      })
      .finally(() => setInFlight(false))
  })

  const flush = React.useEffectEvent((keepalive: boolean) => {
    const sent = changedFields(doc, saved)
    if (sent.length === 0) return
    const payload = updatePayload(doc, sent)
    const small = JSON.stringify(payload).length < KEEPALIVE_MAX_CHARS
    api
      .updateFloorPlan(uuid, payload, keepalive && small)
      .then(onSaved)
      .catch(() => undefined)
  })

  React.useEffect(() => {
    if (paused || inFlight || fields.length === 0) return
    let delay = SAVE_DELAY_MS
    if (failure && failure.doc === doc) {
      if (!failure.retry) return
      delay = RETRY_DELAY_MS
    }
    const timer = window.setTimeout(() => save(), delay)
    return () => window.clearTimeout(timer)
  }, [doc, fields, paused, inFlight, failure])

  React.useEffect(() => {
    const onHide = () => flush(true)
    window.addEventListener("pagehide", onHide)
    return () => {
      window.removeEventListener("pagehide", onHide)
      flush(false)
    }
  }, [])

  if (failure && failure.doc === doc && !inFlight) return "failed"
  return fields.length > 0 || inFlight ? "saving" : "saved"
}
