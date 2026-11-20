"use client"

import * as React from "react"
import { BuildingIcon, HouseIcon, MapPinIcon, StoreIcon, WarehouseIcon, type LucideIcon } from "lucide-react"

import { useSession } from "@/components/shell/session"
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import type { Site, SiteKind } from "@/lib/types"
import { cn } from "@/lib/utils"

const KIND_ICONS: Record<SiteKind, LucideIcon> = {
  home: HouseIcon,
  store: StoreIcon,
  office: BuildingIcon,
  warehouse: WarehouseIcon,
  other: MapPinIcon,
}

const TRIGGER = "h-8 w-auto min-w-0 max-w-[9.5rem] gap-1.5 px-2 font-mono text-[11px] sm:max-w-60 sm:px-2.5 md:max-w-80"

function SiteLabel({ site, showOrganisation }: { site: Site; showOrganisation: boolean }) {
  const Icon = KIND_ICONS[site.kind] ?? MapPinIcon
  return (
    <span className="flex min-w-0 items-center gap-1.5">
      <Icon aria-hidden className="size-3.5 shrink-0 text-text-3" />
      {showOrganisation ? (
        <>
          <span className="hidden max-w-36 truncate text-text-3 md:inline">{site.organisation_name}</span>
          <span aria-hidden className="hidden text-text-3 md:inline">
            /
          </span>
        </>
      ) : null}
      <span className="truncate">{site.name}</span>
    </span>
  )
}

function groupByOrganisation(sites: Site[]): { uuid: string; name: string; sites: Site[] }[] {
  const groups: { uuid: string; name: string; sites: Site[] }[] = []
  for (const site of sites) {
    const group = groups.find((item) => item.uuid === site.organisation)
    if (group) group.sites.push(site)
    else groups.push({ uuid: site.organisation, name: site.organisation_name, sites: [site] })
  }
  return groups
}

/**
 * The organisation and site picker of the top bar. Switching reloads the console on the chosen site; with a single
 * site it only names it.
 */
export function SiteSwitcher({ className }: { className?: string }) {
  const { sites, site, switchSite } = useSession()
  if (!site) return null

  const label = `${site.organisation_name} / ${site.name}`

  if (sites.length < 2) {
    return (
      <div
        role="group"
        aria-label={`Site, ${label}`}
        className={cn("flex items-center rounded-md text-foreground", TRIGGER, className)}
      >
        <SiteLabel site={site} showOrganisation />
      </div>
    )
  }

  return (
    <Select value={site.uuid} onValueChange={switchSite}>
      <SelectTrigger aria-label={`Site, ${label}`} className={cn(TRIGGER, className)}>
        <SelectValue>
          <SiteLabel site={site} showOrganisation />
        </SelectValue>
      </SelectTrigger>
      <SelectContent align="start" className="w-auto min-w-56">
        {groupByOrganisation(sites).map((group, index) => (
          <React.Fragment key={group.uuid}>
            {index > 0 ? <SelectSeparator /> : null}
            <SelectGroup>
              <SelectLabel>{group.name}</SelectLabel>
              {group.sites.map((item) => (
                <SelectItem key={item.uuid} value={item.uuid}>
                  <SiteLabel site={item} showOrganisation={false} />
                </SelectItem>
              ))}
            </SelectGroup>
          </React.Fragment>
        ))}
      </SelectContent>
    </Select>
  )
}
