"use client"

import * as React from "react"
import { LogOutIcon } from "lucide-react"
import { toast } from "sonner"

import { ROLE_LABELS } from "@/components/shell/navigation"
import { useSession } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { LOGIN_PATH, api, errorMessage } from "@/lib/api"

function initials(name: string): string {
  const parts = name.split(/[\s._@-]+/).filter(Boolean)
  const letters = parts.length > 1 ? `${parts[0][0]}${parts[1][0]}` : name.slice(0, 2)
  return letters.toUpperCase()
}

/** The account menu of the top bar: who is signed in, their role at the current site, and sign out. */
export function UserMenu() {
  const { user, site, role, platformAdmin } = useSession()
  const [busy, setBusy] = React.useState(false)
  const display = user.name || user.username

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
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon" aria-label={`Account, ${display}`}>
          <span
            aria-hidden
            className="flex size-7 items-center justify-center rounded-full border border-hairline bg-surface-3 font-mono text-[10px] text-foreground"
          >
            {initials(display)}
          </span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="w-64">
        <DropdownMenuLabel className="flex flex-col gap-0.5 py-2">
          <span className="truncate text-[13px] text-foreground">{display}</span>
          <span className="truncate font-data text-[11px] text-text-3">{user.email ?? user.username}</span>
          {role && site ? (
            <span className="truncate text-[12px] text-text-2">
              {ROLE_LABELS[role]} at {site.name}
            </span>
          ) : null}
          {platformAdmin ? <span className="text-[12px] text-text-2">Platform admin</span> : null}
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem disabled={busy} onSelect={() => void signOut()}>
          <LogOutIcon />
          Sign out
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
