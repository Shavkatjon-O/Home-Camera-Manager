"use client"

import * as React from "react"

import { api, errorMessage, isAbort } from "@/lib/api"
import type { Site } from "@/lib/types"

const SITE_COOKIE = "sss_site"

interface CurrentSite {
  site: Site | null
  loaded: boolean
  error: string | null
  isManager: boolean
}

function readSiteCookie(): string | null {
  const prefix = `${SITE_COOKIE}=`
  const part = document.cookie.split("; ").find((item) => item.startsWith(prefix))
  return part ? decodeURIComponent(part.slice(prefix.length)) : null
}

/**
 * Loads the sites of the signed in user and picks the current one, the same way the site switcher does.
 *
 * @returns The current site, whether loading finished, an error message and whether the user manages the organisation.
 */
export function useCurrentSite(): CurrentSite {
  const [state, setState] = React.useState<{ site: Site | null; loaded: boolean; error: string | null }>({
    site: null,
    loaded: false,
    error: null,
  })

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .listSites(controller.signal)
      .then(({ items }) => {
        const saved = readSiteCookie()
        const site = items.find((item) => item.uuid === saved) ?? items[0] ?? null
        setState({ site, loaded: true, error: null })
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setState({ site: null, loaded: true, error: errorMessage(err) })
      })
    return () => controller.abort()
  }, [])

  const isManager = state.site?.role === "admin" || state.site?.role === "owner"
  return { ...state, isManager }
}
