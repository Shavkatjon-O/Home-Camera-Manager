"use client"

import * as React from "react"
import { BuildingIcon } from "lucide-react"

import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { api, isAbort } from "@/lib/api"
import type { Site } from "@/lib/types"

const SITE_COOKIE = "sss_site"
const YEAR_SECONDS = 31536000

function readSiteCookie(): string | null {
  const prefix = `${SITE_COOKIE}=`
  const part = document.cookie.split("; ").find((item) => item.startsWith(prefix))
  return part ? decodeURIComponent(part.slice(prefix.length)) : null
}

export function SiteSwitcher() {
  const [sites, setSites] = React.useState<Site[]>([])
  const [current, setCurrent] = React.useState<string | null>(null)

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .listSites(controller.signal)
      .then(({ items }) => {
        const saved = readSiteCookie()
        setSites(items)
        setCurrent(items.find((site) => site.uuid === saved)?.uuid ?? items[0]?.uuid ?? null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setSites([])
      })
    return () => controller.abort()
  }, [])

  if (sites.length < 2 || !current) return null

  const showOrganisation = new Set(sites.map((site) => site.organisation)).size > 1
  const label = (site: Site) => (showOrganisation ? `${site.organisation_name} / ${site.name}` : site.name)
  const active = sites.find((site) => site.uuid === current) ?? sites[0]

  const change = (uuid: string) => {
    if (uuid === current) return
    document.cookie = `${SITE_COOKIE}=${encodeURIComponent(uuid)}; path=/; max-age=${YEAR_SECONDS}; SameSite=Lax`
    window.location.reload()
  }

  return (
    <Select value={current} onValueChange={change}>
      <SelectTrigger aria-label={`Site, ${label(active)}`} className="w-auto max-w-40 gap-1.5 px-2 font-mono text-[11px] sm:max-w-56 sm:px-2.5">
        <SelectValue>
          <span className="flex min-w-0 items-center gap-1.5">
            <BuildingIcon aria-hidden className="size-3.5 shrink-0 text-text-3" />
            <span className="hidden truncate sm:inline">{label(active)}</span>
          </span>
        </SelectValue>
      </SelectTrigger>
      <SelectContent align="end" className="min-w-40">
        {sites.map((site) => (
          <SelectItem key={site.uuid} value={site.uuid}>
            {label(site)}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  )
}
