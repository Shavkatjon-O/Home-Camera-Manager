"use client"

import * as React from "react"
import { CircleAlertIcon } from "lucide-react"

import { EmptyState } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { ApiError, api, errorMessage, isAbort } from "@/lib/api"
import type { Camera, User } from "@/lib/types"

const POLL_MS = 10000

interface SessionValue {
  user: User
  cameras: Camera[]
  loaded: boolean
  error: string | null
  refresh: () => Promise<void>
}

const SessionContext = React.createContext<SessionValue | null>(null)

export function useSession(): SessionValue {
  const value = React.useContext(SessionContext)
  if (!value) throw new Error("useSession needs a SessionProvider")
  return value
}

export function SessionProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = React.useState<User | null>(null)
  const [authError, setAuthError] = React.useState<string | null>(null)
  const [cameras, setCameras] = React.useState<Camera[]>([])
  const [loaded, setLoaded] = React.useState(false)
  const [error, setError] = React.useState<string | null>(null)

  const refresh = React.useCallback(async () => {
    try {
      const page = await api.listCameras({ order: "position", page_size: 100 })
      setCameras(page.items)
      setError(null)
    } catch (err) {
      if (!isAbort(err)) setError(errorMessage(err))
    } finally {
      setLoaded(true)
    }
  }, [])

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .me(true, controller.signal)
      .then(setUser)
      .catch((err: unknown) => {
        if (isAbort(err)) return
        if (err instanceof ApiError && err.status === 401) return
        setAuthError(errorMessage(err))
      })
    return () => controller.abort()
  }, [])

  React.useEffect(() => {
    if (!user) return
    const run = () => {
      void refresh()
    }
    const first = window.setTimeout(run, 0)
    const timer = window.setInterval(run, POLL_MS)
    const onVisible = () => {
      if (document.visibilityState === "visible") run()
    }
    document.addEventListener("visibilitychange", onVisible)
    return () => {
      window.clearTimeout(first)
      window.clearInterval(timer)
      document.removeEventListener("visibilitychange", onVisible)
    }
  }, [user, refresh])

  const value = React.useMemo<SessionValue | null>(
    () => (user ? { user, cameras, loaded, error, refresh } : null),
    [user, cameras, loaded, error, refresh],
  )

  if (authError) {
    return (
      <div className="flex h-dvh items-center justify-center bg-background">
        <EmptyState icon={<CircleAlertIcon />} title="Cannot reach the server">
          <span className="font-data text-xs">{authError}</span>
          <Button variant="outline" onClick={() => window.location.reload()}>
            Try again
          </Button>
        </EmptyState>
      </div>
    )
  }

  if (!value) return <div className="h-dvh bg-background" />

  return <SessionContext.Provider value={value}>{children}</SessionContext.Provider>
}
