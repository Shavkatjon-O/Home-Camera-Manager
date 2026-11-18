import * as React from "react"
import { Loader2Icon } from "lucide-react"

import { statusLabel } from "@/lib/format"
import { cn } from "@/lib/utils"

export function StatusDot({ online, className }: { online: boolean | null; className?: string }) {
  return (
    <span
      role="img"
      aria-label={statusLabel(online)}
      className={cn(
        "inline-block size-2 shrink-0 rounded-full",
        online === true && "bg-status-ok",
        online === false && "bg-status-err",
        online === null && "bg-status-off",
        className,
      )}
    />
  )
}

export function Chip({ className, ...props }: React.ComponentProps<"span">) {
  return (
    <span
      className={cn(
        "inline-flex h-6 items-center gap-1.5 rounded-md bg-chip px-2 font-data text-[11px] whitespace-nowrap text-text-2",
        className,
      )}
      {...props}
    />
  )
}

export function Spinner({ className }: { className?: string }) {
  return <Loader2Icon aria-hidden className={cn("size-4 animate-spin text-text-3", className)} />
}

export function EmptyState({
  icon,
  title,
  children,
  className,
}: {
  icon?: React.ReactNode
  title: string
  children?: React.ReactNode
  className?: string
}) {
  return (
    <div className={cn("flex h-full min-h-48 flex-col items-center justify-center gap-3 p-8 text-center", className)}>
      {icon ? <div className="text-text-3 [&_svg]:size-5">{icon}</div> : null}
      <div className="text-[14px] text-foreground">{title}</div>
      {children ? (
        <div className="flex max-w-sm flex-col items-center gap-3 text-[13px] text-text-3">{children}</div>
      ) : null}
    </div>
  )
}

export function LoadingState({ label, className }: { label: string; className?: string }) {
  return (
    <div className={cn("flex h-full min-h-48 items-center justify-center gap-2 text-[13px] text-text-3", className)}>
      <Spinner />
      {label}
    </div>
  )
}
