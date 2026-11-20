"use client"

import * as React from "react"
import Link from "next/link"
import { CctvIcon, MenuIcon } from "lucide-react"

import { ArmModeSelect } from "@/components/analytics/arm-mode"
import { hasRole } from "@/components/shell/navigation"
import { NotificationsMenu } from "@/components/shell/notifications-menu"
import { useSession } from "@/components/shell/session"
import { Sidebar, SidebarNav } from "@/components/shell/sidebar"
import { SiteSwitcher } from "@/components/shell/site-switcher"
import { StatusIndicator } from "@/components/shell/status-indicator"
import { UserMenu } from "@/components/shell/user-menu"
import { Button } from "@/components/ui/button"
import { Sheet, SheetContent, SheetDescription, SheetTitle, SheetTrigger } from "@/components/ui/sheet"

const PRODUCT = "Smart Surveillance"

function BrandMark() {
  return (
    <span
      aria-hidden
      className="flex size-7 shrink-0 items-center justify-center rounded-md bg-foreground text-background"
    >
      <CctvIcon className="size-4" />
    </span>
  )
}

function Brand() {
  return (
    <Link
      href="/"
      aria-label={`${PRODUCT}, wall`}
      className="flex shrink-0 items-center gap-2 rounded-md text-[13px] font-medium text-foreground"
    >
      <BrandMark />
      <span className="hidden md:inline">{PRODUCT}</span>
    </Link>
  )
}

function MobileNav() {
  const [open, setOpen] = React.useState(false)
  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon" aria-label="Open navigation" className="md:hidden">
          <MenuIcon className="size-4" />
        </Button>
      </SheetTrigger>
      <SheetContent aria-describedby="mobile-nav-description">
        <div className="flex h-[58px] shrink-0 items-center gap-2 border-b border-hairline px-4">
          <BrandMark />
          <SheetTitle>{PRODUCT}</SheetTitle>
          <SheetDescription id="mobile-nav-description" className="sr-only">
            Pages of the console
          </SheetDescription>
        </div>
        <nav aria-label="Main" className="min-h-0 flex-1 overflow-y-auto px-3 py-4">
          <SidebarNav onNavigate={() => setOpen(false)} />
        </nav>
      </SheetContent>
    </Sheet>
  )
}

function TopBar() {
  const { role } = useSession()
  return (
    <header className="flex h-[58px] shrink-0 items-center gap-1.5 border-b border-hairline bg-surface px-2 sm:gap-2 sm:px-4">
      <MobileNav />
      <Brand />
      <span aria-hidden className="mx-1 hidden h-5 w-px bg-hairline sm:block" />
      <SiteSwitcher />
      <div className="min-w-0 flex-1" />
      <div className="flex shrink-0 items-center gap-1 sm:gap-1.5">
        <StatusIndicator />
        <ArmModeSelect readOnly={!hasRole(role, "operator")} />
        <NotificationsMenu />
        <UserMenu />
      </div>
    </header>
  )
}

/**
 * The application shell around every signed-in page: the 58 px top bar, the sidebar, or the navigation drawer on
 * narrow screens, and the content area where each page renders its own page header and body.
 */
export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-dvh flex-col overflow-hidden bg-background">
      <a
        href="#content"
        className="sr-only z-50 rounded-md bg-surface px-3 py-2 text-[13px] text-foreground focus:not-sr-only focus:absolute focus:top-2 focus:left-2"
      >
        Skip to content
      </a>
      <TopBar />
      <div className="flex min-h-0 flex-1">
        <Sidebar />
        <div id="content" tabIndex={-1} className="flex min-h-0 min-w-0 flex-1 flex-col outline-none">
          {children}
        </div>
      </div>
    </div>
  )
}
