"use client"

import { cn } from "@/lib/utils"

/** One choice of a segmented control. */
export interface SegmentedOption<T extends string> {
  value: T
  label: string
  disabled?: boolean
}

/** A row of mutually exclusive choices, announced as a radio group. */
export function Segmented<T extends string>({
  label,
  value,
  options,
  onChange,
  className,
}: {
  label: string
  value: T
  options: SegmentedOption<T>[]
  onChange: (value: T) => void
  className?: string
}) {
  return (
    <div
      role="radiogroup"
      aria-label={label}
      className={cn("flex h-8 items-center gap-0.5 rounded-md border border-input p-0.5", className)}
    >
      {options.map((option) => {
        const active = option.value === value
        return (
          <button
            key={option.value}
            type="button"
            role="radio"
            aria-checked={active}
            disabled={option.disabled}
            onClick={() => onChange(option.value)}
            className={cn(
              "h-full rounded-[4px] px-2 font-mono text-[11px] text-text-2 transition-colors hover:text-foreground disabled:pointer-events-none disabled:opacity-40",
              active && "bg-surface-3 text-foreground",
            )}
          >
            {option.label}
          </button>
        )
      })}
    </div>
  )
}
