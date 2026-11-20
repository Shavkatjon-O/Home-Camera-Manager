"use client"

import * as React from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  ActivityIcon,
  BellOffIcon,
  BellRingIcon,
  CctvIcon,
  ChartColumnIcon,
  LayoutGridIcon,
  ListIcon,
  LogOutIcon,
  RadarIcon,
  ScanEyeIcon,
  SearchIcon,
  UsersRoundIcon,
  WifiIcon,
} from "lucide-react"
import { toast } from "sonner"

import { ArmModeSelect } from "@/components/analytics/arm-mode"
import { IconButton } from "@/components/shell/icon-button"
import { Chip, StatusDot } from "@/components/shell/primitives"
import { useSession } from "@/components/shell/session"
import { LOGIN_PATH, api, errorMessage } from "@/lib/api"
import { setAlertsMuted, useAlertsMuted, useUnseenAlerts } from "@/lib/events"
import { formatClock } from "@/lib/format"
import { useClockSeconds } from "@/lib/stores"
import { cn } from "@/lib/utils"

const EVENTS_HREF = "/events/"
const BADGE_MAX = 99

const TABS = [
  { href: "/", label: "Wall", icon: LayoutGridIcon, match: (path: string) => path === "/" || path.startsWith("/camera/") },
  { href: "/cameras/", label: "Cameras", icon: ListIcon, match: (path: string) => path.startsWith("/cameras/") },
  { href: EVENTS_HREF, label: "Events", icon: ScanEyeIcon, match: (path: string) => path.startsWith("/events/") },
  { href: "/counts/", label: "Counts", icon: ChartColumnIcon, match: (path: string) => path.startsWith("/counts/") },
  { href: "/people/", label: "People", icon: UsersRoundIcon, match: (path: string) => path.startsWith("/people/") },
  { href: "/search/", label: "Search", icon: SearchIcon, match: (path: string) => path.startsWith("/search/") },
  { href: "/discover/", label: "Discover", icon: RadarIcon, match: (path: string) => path.startsWith("/discover/") },
  { href: "/coverage/", label: "Coverage", icon: WifiIcon, match: (path: string) => path.startsWith("/coverage/") },
  { href: "/health/", label: "Health", icon: ActivityIcon, match: (path: string) => path.startsWith("/health/") },
]

function normalize(path: string | null): string {
  if (!path) return "/"
  return path.endsWith("/") ? path : `${path}/`
}

function NavTabs() {
  const pathname = normalize(usePathname())
  const navRef = React.useRef<HTMLElement>(null)
  const unseen = useUnseenAlerts()

  React.useEffect(() => {
    const nav = navRef.current
    if (!nav) return
    const reveal = () => {
      const active = nav.querySelector<HTMLElement>("[aria-current='page']")
      if (!active) return
      const bounds = nav.getBoundingClientRect()
      const box = active.getBoundingClientRect()
      if (box.right > bounds.right) nav.scrollLeft += box.right - bounds.right
      else if (box.left < bounds.left) nav.scrollLeft -= bounds.left - box.left
    }
    reveal()
    const observer = new ResizeObserver(reveal)
    observer.observe(nav)
    return () => observer.disconnect()
  }, [pathname])

  return (
    <nav
      ref={navRef}
      aria-label="Sections"
      className="flex h-full min-w-0 items-stretch gap-0.5 overflow-x-auto [scrollbar-width:none]"
    >
      {TABS.map((tab) => {
        const active = tab.match(pathname)
        const Icon = tab.icon
        const badge = tab.href === EVENTS_HREF && !active && unseen > 0 ? unseen : 0
        return (
          <Link
            key={tab.href}
            href={tab.href}
            aria-label={badge ? `${tab.label}, ${badge} new ${badge === 1 ? "alert" : "alerts"}` : tab.label}
            aria-current={active ? "page" : undefined}
            className={cn(
              "relative flex shrink-0 items-center px-2 font-mono text-xs transition-colors sm:px-2.5",
              active
                ? "text-foreground after:absolute after:inset-x-2 after:bottom-0 after:h-[2px] after:bg-foreground"
                : "text-text-2 hover:text-foreground",
            )}
          >
            <Icon aria-hidden className="size-4 sm:hidden" />
            <span className="hidden sm:inline">{tab.label}</span>
            {badge ? (
              <span
                aria-hidden
                className="ml-1 inline-flex h-4 min-w-4 items-center justify-center rounded-full bg-status-err px-1 font-data text-[10px] leading-none text-white"
              >
                {badge > BADGE_MAX ? `${BADGE_MAX}+` : badge}
              </span>
            ) : null}
          </Link>
        )
      })}
    </nav>
  )
}

function Clock() {
  const seconds = useClockSeconds()
  return (
    <Chip aria-label="Current time" className="min-w-[68px] justify-center">
      {seconds ? formatClock(new Date(seconds * 1000)) : "--:--:--"}
    </Chip>
  )
}

function OnlineChip() {
  const { cameras, loaded, error } = useSession()
  if (!loaded) return null
  if (error) return <Chip className="text-danger">Status unavailable</Chip>
  const enabled = cameras.filter((camera) => camera.enabled)
  if (enabled.length === 0) return <Chip>No cameras</Chip>
  const online = enabled.filter((camera) => camera.status.online === true).length
  const offline = enabled.some((camera) => camera.status.online === false)
  return (
    <Chip>
      <StatusDot online={online === enabled.length ? true : offline ? false : null} />
      {online} of {enabled.length} online
    </Chip>
  )
}

function AlertsToggle() {
  const muted = useAlertsMuted()
  return (
    <IconButton
      label={muted ? "Unmute event alerts" : "Mute event alerts"}
      aria-pressed={muted}
      onClick={() => setAlertsMuted(!muted)}
    >
      {muted ? <BellOffIcon /> : <BellRingIcon />}
    </IconButton>
  )
}

function SignOutButton() {
  const [busy, setBusy] = React.useState(false)
  const signOut = async () => {
    setBusy(true)
    try {
      await api.logout()
      window.location.replace(LOGIN_PATH)
    } catch (err) {
      setBusy(false)
      toast.error(errorMessage(err))
    }
  }
  return (
    <IconButton label="Sign out" disabled={busy} onClick={signOut}>
      <LogOutIcon />
    </IconButton>
  )
}

export function AppFrame({
  status,
  actions,
  wideActions = false,
  children,
}: {
  status?: React.ReactNode
  actions?: React.ReactNode
  wideActions?: boolean
  children: React.ReactNode
}) {
  return (
    <div className="flex h-dvh flex-col overflow-hidden bg-background">
      <header className="flex h-[58px] shrink-0 items-center gap-2 border-b border-hairline bg-surface px-3 sm:gap-3 sm:px-4">
        <CctvIcon aria-hidden className="size-4 shrink-0 text-text-2" />
        <NavTabs />
        <div className="min-w-0 flex-1" />
        <div className="hidden items-center gap-2 sm:flex">
          <OnlineChip />
          {status}
          <div className="hidden md:contents">
            <Clock />
          </div>
        </div>
        <div className="flex items-center gap-1.5">
          {actions}
          <ArmModeSelect className={wideActions ? "max-sm:hidden" : undefined} />
          <AlertsToggle />
          <SignOutButton />
        </div>
      </header>
      <div className="flex min-h-0 flex-1">{children}</div>
    </div>
  )
}
