"use client"

import * as React from "react"

import { errorMessage, isAbort } from "@/lib/api"
import type { Page } from "@/lib/types"

export interface PagedQuery<T> {
  data: Page<T> | null
  error: string | null
  page: number
  setPage: (page: number) => void
  refresh: () => void
  update: (change: (data: Page<T>) => Page<T>) => void
}

export function usePagedQuery<T>(
  key: string,
  load: (page: number, signal: AbortSignal) => Promise<Page<T>>,
  pageSize: number,
): PagedQuery<T> {
  const [pageState, setPageState] = React.useState({ key, page: 1 })
  const [reload, setReload] = React.useState(0)
  const [result, setResult] = React.useState<{ key: string; data: Page<T> } | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const page = pageState.key === key ? pageState.page : 1

  React.useEffect(() => {
    const controller = new AbortController()
    load(page, controller.signal)
      .then((data) => {
        if (data.items.length === 0 && data.total > 0 && page > 1) {
          setPageState({ key, page: Math.max(1, Math.ceil(data.total / pageSize)) })
          return
        }
        setResult({ key, data })
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(errorMessage(err))
      })
    return () => controller.abort()
  }, [key, load, page, pageSize, reload])

  const setPage = React.useCallback((next: number) => setPageState({ key, page: Math.max(1, next) }), [key])
  const refresh = React.useCallback(() => setReload((value) => value + 1), [])
  const update = React.useCallback(
    (change: (data: Page<T>) => Page<T>) =>
      setResult((current) => (current ? { ...current, data: change(current.data) } : current)),
    [],
  )

  return {
    data: result && result.key === key ? result.data : null,
    error,
    page,
    setPage,
    refresh,
    update,
  }
}
