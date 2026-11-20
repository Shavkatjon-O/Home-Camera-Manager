"use client"

import { PERSON_COLORS, safeColor, sameColor, type PersonColor } from "@/lib/people"
import { cn } from "@/lib/utils"

export function ColorPicker({
  value,
  onChange,
  labelledBy,
  className,
}: {
  value: string | null
  onChange: (value: string) => void
  labelledBy?: string
  className?: string
}) {
  const current = safeColor(value)
  const options: PersonColor[] =
    current && !PERSON_COLORS.some((option) => sameColor(option.value, current))
      ? [...PERSON_COLORS, { value: current, name: "Current color" }]
      : PERSON_COLORS
  return (
    <div role="radiogroup" aria-labelledby={labelledBy} className={cn("flex flex-wrap gap-2", className)}>
      {options.map((option) => {
        const active = sameColor(option.value, current)
        return (
          <button
            key={option.value}
            type="button"
            role="radio"
            aria-checked={active}
            aria-label={option.name}
            title={option.name}
            onClick={() => onChange(option.value)}
            className={cn(
              "size-6 rounded-full border transition-shadow",
              active && "ring-2 ring-foreground ring-offset-2 ring-offset-surface",
            )}
            style={{ backgroundColor: option.value, borderColor: option.value }}
          />
        )
      })}
    </div>
  )
}
