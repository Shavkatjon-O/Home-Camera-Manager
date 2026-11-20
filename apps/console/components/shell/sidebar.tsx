"use client"

import * as React from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { PanelLeftCloseIcon, PanelLeftOpenIcon } from "lucide-react"

import { isActive, normalizePath, visibleGroups, type NavItem } from "@/components/shell/navigation"
import { useSession } from "@/components/shell/session"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { setSidebarCollapsed, useMediaQuery, useSidebarCollapsed } from "@/lib/stores"
import { cn } from "@/lib/utils"

const WIDE = "(min-width: 1024px)"

function NavLink({
  item,
  active,
  rail,
  onNavigate,
}: {
  item: NavItem
  active: boolean
  rail: boolean
  onNavigate?: () => void
}) {
  const Icon = item.icon
  const link = (
    <Link
      href={item.href}
      aria-current={active ? "page" : undefined}
      aria-label={rail ? item.label : undefined}
      onClick={onNavigate}
      className={cn(
        "flex h-8 items-center gap-2.5 rounded-md font-mono text-xs transition-colors",
        rail ? "w-8 justify-center" : "px-2.5",
        active ? "bg-surface-3 text-foreground" : "text-text-2 hover:bg-surface-2 hover:text-foreground",
      )}
    >
      <Icon aria-hidden className="size-4 shrink-0" />
      {rail ? null : <span className="truncate">{item.label}</span>}
    </Link>
  )
  if (!rail) return link
  return (
    <Tooltip>
      <TooltipTrigger asChild>{link}</TooltipTrigger>
      <TooltipContent side="right">{item.label}</TooltipContent>
    </Tooltip>
  )
}

/**
 * The navigation links grouped by business domain, showing only the pages the member's role may open. As a rail it
 * shows icons only, with each label in a tooltip; onNavigate lets a drawer close when a link is followed.
 */
export function SidebarNav({ rail = false, onNavigate }: { rail?: boolean; onNavigate?: () => void }) {
  const path = normalizePath(usePathname())
  const { role, platformAdmin } = useSession()
  const groups = visibleGroups(role, platformAdmin)
  return (
    <div className={cn("flex flex-col", rail ? "items-center gap-3" : "gap-5")}>
      {groups.map((group, index) => (
        <section key={group.label} aria-labelledby={`nav-${group.label}`} className="flex flex-col gap-0.5">
          {rail ? (
            <>
              <h2 id={`nav-${group.label}`} className="sr-only">
                {group.label}
              </h2>
              {index > 0 ? <span aria-hidden className="mx-auto mb-2 h-px w-6 bg-hairline" /> : null}
            </>
          ) : (
            <h2 id={`nav-${group.label}`} className="px-2.5 pb-1 text-[11px] text-text-3">
              {group.label}
            </h2>
          )}
          <ul className={cn("flex flex-col gap-0.5", rail && "items-center")}>
            {group.items.map((item) => (
              <li key={item.href}>
                <NavLink item={item} active={isActive(item, path)} rail={rail} onNavigate={onNavigate} />
              </li>
            ))}
          </ul>
        </section>
      ))}
    </div>
  )
}

/**
 * The left sidebar on screens from 768 px: the full list from 1024 px, which the member can collapse to an icon
 * rail and the browser remembers, and always the rail below that.
 */
export function Sidebar() {
  const collapsed = useSidebarCollapsed()
  const wide = useMediaQuery(WIDE)
  const rail = collapsed || !wide
  return (
    <aside
      aria-label="Sidebar"
      className={cn(
        "hidden shrink-0 flex-col border-r border-hairline bg-surface md:flex",
        rail ? "w-14" : "w-56",
      )}
    >
      <nav aria-label="Main" className="min-h-0 flex-1 overflow-y-auto px-3 py-4">
        <SidebarNav rail={rail} />
      </nav>
      {wide ? (
        <div className={cn("border-t border-hairline p-2", rail && "flex justify-center")}>
          <button
            type="button"
            aria-label={collapsed ? "Expand sidebar" : "Collapse sidebar"}
            aria-expanded={!collapsed}
            onClick={() => setSidebarCollapsed(!collapsed)}
            className={cn(
              "flex h-8 items-center gap-2.5 rounded-md font-mono text-xs text-text-3 transition-colors hover:bg-surface-2 hover:text-foreground",
              rail ? "w-8 justify-center" : "w-full px-2.5",
            )}
          >
            {collapsed ? (
              <PanelLeftOpenIcon aria-hidden className="size-4" />
            ) : (
              <PanelLeftCloseIcon aria-hidden className="size-4" />
            )}
            {rail ? null : <span>Collapse</span>}
          </button>
        </div>
      ) : null}
    </aside>
  )
}
