import { cn } from "@/lib/cn"

const LABELS = {
  live: "Live",
  beta: "Beta",
  planned: "Planned",
  untested: "Not yet run",
} as const

/** How far a product or feature is: running, running as a beta, designed only, or built and never run. */
export type StatusKind = keyof typeof LABELS

/**
 * A small chip in the console's style that marks a product or feature as live, beta, planned or not yet run.
 *
 * @param props The props.
 * @param props.kind The status.
 * @param props.className Extra classes.
 * @returns The chip.
 */
export function Status({ kind, className }: { kind: StatusKind; className?: string }) {
  return (
    <span
      className={cn(
        "not-prose inline-flex h-5 items-center gap-1.5 rounded-md bg-fd-secondary px-1.5 align-middle font-mono text-[11px] whitespace-nowrap text-fd-muted-foreground",
        className,
      )}
    >
      <span
        aria-hidden
        className={cn(
          "inline-block size-1.5 rounded-full",
          kind === "live" && "bg-[var(--status-ok)]",
          kind === "beta" && "bg-[var(--status-warn)]",
          kind === "planned" && "bg-[var(--status-off)]",
          kind === "untested" && "bg-[var(--status-off)]",
        )}
      />
      {LABELS[kind]}
    </span>
  )
}
