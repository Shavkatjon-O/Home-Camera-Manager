import {
  ActivityIcon,
  CctvIcon,
  ChartColumnIcon,
  LayoutGridIcon,
  RadarIcon,
  ScanEyeIcon,
  SearchIcon,
  UsersRoundIcon,
  WifiIcon,
  type LucideIcon,
} from "lucide-react"

import type { SiteRole } from "@/lib/types"

/** One page in the sidebar. */
export interface NavItem {
  href: string
  label: string
  description: string
  icon: LucideIcon
  also?: string[]
  minRole?: SiteRole
  platformAdmin?: boolean
}

/** A business domain of the sidebar and its pages. */
export interface NavGroup {
  label: string
  items: NavItem[]
}

const ROLE_RANK: Record<SiteRole, number> = { viewer: 0, operator: 1, admin: 2, owner: 3 }

/** Display names of the member roles. */
export const ROLE_LABELS: Record<SiteRole, string> = {
  viewer: "Viewer",
  operator: "Operator",
  admin: "Admin",
  owner: "Owner",
}

/** The console's pages grouped by business domain, in sidebar order. */
export const NAV_GROUPS: NavGroup[] = [
  {
    label: "Monitor",
    items: [
      {
        href: "/",
        label: "Wall",
        description: "Live view of every enabled camera",
        icon: LayoutGridIcon,
        also: ["/camera/"],
      },
      {
        href: "/events/",
        label: "Events",
        description: "Detections, alerts and camera problems as they happen",
        icon: ScanEyeIcon,
      },
      {
        href: "/counts/",
        label: "Counts",
        description: "Line crossings and area occupancy by hour",
        icon: ChartColumnIcon,
      },
    ],
  },
  {
    label: "Investigate",
    items: [
      {
        href: "/search/",
        label: "Search",
        description: "Find people and vehicles across recorded events",
        icon: SearchIcon,
      },
      {
        href: "/people/",
        label: "People",
        description: "Known people and the unknown faces the cameras saw",
        icon: UsersRoundIcon,
        minRole: "admin",
      },
    ],
  },
  {
    label: "Devices",
    items: [
      {
        href: "/cameras/",
        label: "Cameras",
        description: "Cameras of this site and their order on the wall",
        icon: CctvIcon,
      },
      {
        href: "/discover/",
        label: "Add camera",
        description: "Scan the network for cameras and register them",
        icon: RadarIcon,
        minRole: "admin",
      },
      {
        href: "/health/",
        label: "Health",
        description: "Reachability and outages of cameras and network devices",
        icon: ActivityIcon,
      },
    ],
  },
  {
    label: "Site",
    items: [
      {
        href: "/coverage/",
        label: "Coverage",
        description: "Floor plans, router placement and Wi-Fi signal",
        icon: WifiIcon,
      },
    ],
  },
]

/**
 * Checks a member's role against the least role a page needs.
 *
 * @param role The member's role at the current site, or null while unknown.
 * @param minRole The least role the page needs, if any.
 * @return Whether the member may open the page.
 */
export function hasRole(role: SiteRole | null, minRole: SiteRole | undefined): boolean {
  if (!minRole) return true
  return role !== null && ROLE_RANK[role] >= ROLE_RANK[minRole]
}

/**
 * Lists the groups and pages a member may see, leaving out empty groups.
 *
 * @param role The member's role at the current site, or null while unknown.
 * @param platformAdmin Whether the member administers the whole platform.
 * @return The visible groups in sidebar order.
 */
export function visibleGroups(role: SiteRole | null, platformAdmin: boolean): NavGroup[] {
  return NAV_GROUPS.map((group) => ({
    ...group,
    items: group.items.filter((item) => (item.platformAdmin ? platformAdmin : hasRole(role, item.minRole))),
  })).filter((group) => group.items.length > 0)
}

/**
 * Adds the trailing slash the static export uses to a path.
 *
 * @param path A path name, or null before the router knows it.
 * @return The path with one trailing slash.
 */
export function normalizePath(path: string | null): string {
  if (!path) return "/"
  return path.endsWith("/") ? path : `${path}/`
}

/**
 * Checks whether a page is the one shown, or the parent of the one shown.
 *
 * @param item The page.
 * @param path The current path with its trailing slash.
 * @return Whether the sidebar marks the page as current.
 */
export function isActive(item: NavItem, path: string): boolean {
  const prefixes = [item.href, ...(item.also ?? [])]
  return prefixes.some((prefix) => (prefix === "/" ? path === "/" : path.startsWith(prefix)))
}

/**
 * Finds the sidebar page that a path belongs to.
 *
 * @param path The current path with its trailing slash.
 * @return The page, or null for a path outside the sidebar.
 */
export function findItem(path: string): NavItem | null {
  for (const group of NAV_GROUPS) {
    const item = group.items.find((candidate) => isActive(candidate, path))
    if (item) return item
  }
  return null
}
