"use client"

import * as React from "react"
import { CircleAlertIcon } from "lucide-react"

import { hasRole } from "@/components/shell/navigation"
import { EmptyState } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { ApiError, api, errorMessage, isAbort } from "@/lib/api"
import type { Camera, Site, SiteRole, User } from "@/lib/types"

const POLL_MS = 10000
const SITE_COOKIE = "sss_site"
const YEAR_SECONDS = 31536000

/** What every page of the console knows about the signed-in member and the site it acts on. */
export interface SessionValue {
  user: User
  cameras: Camera[]
  loaded: boolean
  error: string | null
  refresh: () => Promise<void>
  sites: Site[]
  site: Site | null
  role: SiteRole | null
  platformAdmin: boolean
  switchSite: (uuid: string) => void
}

const SessionContext = React.createContext<SessionValue | null>(null)

function readSiteCookie(): string | null {
  const prefix = `${SITE_COOKIE}=`
  const part = document.cookie.split("; ").find((item) => item.startsWith(prefix))
  return part ? decodeURIComponent(part.slice(prefix.length)) : null
}

/** Reads the signed-in member, the current site's cameras, the sites they may reach and their role there. */
export function useSession(): SessionValue {
  const value = React.useContext(SessionContext)
  if (!value) throw new Error("useSession needs a SessionProvider")
  return value
}

/**
 * Checks the member's role at the current site against the least role an action needs, with the same rule as the
 * sidebar. It only decides what the console shows; the server checks every request itself.
 */
export function useCan(minRole: SiteRole): boolean {
  const { role } = useSession()
  return hasRole(role, minRole)
}

/**
 * Loads the signed-in member, the sites they may reach and the current site's cameras, and polls the cameras.
 * Whether the member administers the platform comes from the account. Renders nothing until the member is known, and a retry screen when the server
 * cannot be reached.
 */
export function SessionProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = React.useState<User | null>(null)
  const [authError, setAuthError] = React.useState<string | null>(null)
  const [cameras, setCameras] = React.useState<Camera[]>([])
  const [loaded, setLoaded] = React.useState(false)
  const [error, setError] = React.useState<string | null>(null)
  const [sites, setSites] = React.useState<Site[]>([])
  const [siteUuid, setSiteUuid] = React.useState<string | null>(null)

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
    const controller = new AbortController()
    api
      .listSites(controller.signal)
      .then(({ items }) => {
        const saved = readSiteCookie()
        setSites(items)
        setSiteUuid(items.find((item) => item.uuid === saved)?.uuid ?? items[0]?.uuid ?? null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setSites([])
      })
    return () => controller.abort()
  }, [user])

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

  const switchSite = React.useCallback(
    (uuid: string) => {
      if (uuid === siteUuid) return
      document.cookie = `${SITE_COOKIE}=${encodeURIComponent(uuid)}; path=/; max-age=${YEAR_SECONDS}; SameSite=Lax`
      window.location.reload()
    },
    [siteUuid],
  )

  const value = React.useMemo<SessionValue | null>(() => {
    if (!user) return null
    const site = sites.find((item) => item.uuid === siteUuid) ?? null
    const platformAdmin = user.is_platform_admin === true
    return { user, cameras, loaded, error, refresh, sites, site, role: site?.role ?? null, platformAdmin, switchSite }
  }, [user, cameras, loaded, error, refresh, sites, siteUuid, switchSite])

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
