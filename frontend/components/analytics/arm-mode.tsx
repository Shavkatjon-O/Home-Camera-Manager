"use client"

import * as React from "react"
import { CalendarClockIcon, HouseIcon, ShieldCheckIcon, ShieldOffIcon, type LucideIcon } from "lucide-react"
import { toast } from "sonner"

import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { ARM_MODES, ARM_MODE_LABELS, changeArmMode, refreshArmMode, useArmMode } from "@/lib/analytics"
import { errorMessage } from "@/lib/api"
import type { ArmMode } from "@/lib/types"
import { cn } from "@/lib/utils"

const ARM_ICONS: Record<ArmMode, LucideIcon> = {
  disarmed: ShieldOffIcon,
  home: HouseIcon,
  away: ShieldCheckIcon,
  schedule: CalendarClockIcon,
}

export function ArmModeSelect({ className }: { className?: string }) {
  const mode = useArmMode()
  const [busy, setBusy] = React.useState(false)

  React.useEffect(() => {
    const load = () => {
      refreshArmMode().catch(() => undefined)
    }
    load()
    const onVisible = () => {
      if (document.visibilityState === "visible") load()
    }
    document.addEventListener("visibilitychange", onVisible)
    return () => document.removeEventListener("visibilitychange", onVisible)
  }, [])

  if (!mode) return null

  const change = async (value: string) => {
    if (value === mode) return
    setBusy(true)
    try {
      await changeArmMode(value as ArmMode)
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(false)
    }
  }

  const Icon = ARM_ICONS[mode]
  return (
    <Select value={mode} disabled={busy} onValueChange={(value) => void change(value)}>
      <SelectTrigger
        aria-label={`Arm mode, ${ARM_MODE_LABELS[mode]}`}
        className={cn("w-auto gap-1.5 px-2 font-mono text-[11px] sm:px-2.5", className)}
      >
        <SelectValue>
          <span className="flex items-center gap-1.5">
            <Icon aria-hidden className={cn("size-3.5", mode === "disarmed" ? "text-text-3" : "text-status-ok")} />
            <span className="hidden sm:inline">{ARM_MODE_LABELS[mode]}</span>
          </span>
        </SelectValue>
      </SelectTrigger>
      <SelectContent align="end" className="min-w-40">
        {ARM_MODES.map((item) => {
          const ItemIcon = ARM_ICONS[item]
          return (
            <SelectItem key={item} value={item}>
              <span className="flex items-center gap-2">
                <ItemIcon aria-hidden className="size-3.5 text-text-3" />
                {ARM_MODE_LABELS[item]}
              </span>
            </SelectItem>
          )
        })}
      </SelectContent>
    </Select>
  )
}
