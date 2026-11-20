"use client"

import * as React from "react"

import { ColorDot, FaceCrop } from "@/components/people/face-parts"
import { Label } from "@/components/ui/label"
import { cn } from "@/lib/utils"

export interface Choice {
  value: string
  label: string
  detail?: string
  color?: string | null
  crops: (string | null)[]
}

export function ChoiceList({
  label,
  choices,
  value,
  onChange,
  className,
}: {
  label: string
  choices: Choice[]
  value: string | null
  onChange: (value: string) => void
  className?: string
}) {
  return (
    <div role="radiogroup" aria-label={label} className={cn("flex flex-col gap-1.5", className)}>
      {choices.map((choice) => {
        const active = choice.value === value
        return (
          <button
            key={choice.value}
            type="button"
            role="radio"
            aria-checked={active}
            onClick={() => onChange(choice.value)}
            className={cn(
              "flex min-w-0 items-center gap-3 rounded-md border px-2.5 py-2 text-left transition-colors",
              active ? "border-hairline-strong bg-surface-2" : "border-hairline hover:border-hairline-strong",
            )}
          >
            <div className="flex shrink-0 gap-1">
              {(choice.crops.length > 0 ? choice.crops : [null]).map((crop, index) => (
                <FaceCrop key={`${crop ?? "none"}-${index}`} sample={crop} className="size-9" sizes="36px" />
              ))}
            </div>
            {choice.color !== undefined ? <ColorDot color={choice.color} /> : null}
            <span className="min-w-0 flex-1 truncate text-[13px] text-foreground">{choice.label}</span>
            {choice.detail ? (
              <span className="shrink-0 font-data text-[11px] text-text-3">{choice.detail}</span>
            ) : null}
          </button>
        )
      })}
    </div>
  )
}

export function Field({
  id,
  label,
  labelId,
  error,
  hint,
  className,
  children,
}: {
  id?: string
  label: string
  labelId?: string
  error?: string | null
  hint?: React.ReactNode
  className?: string
  children: React.ReactNode
}) {
  return (
    <div className={cn("flex min-w-0 flex-col gap-1.5", className)}>
      <Label id={labelId} htmlFor={id}>
        {label}
      </Label>
      {children}
      {hint ? <span className="text-[11px] text-text-3">{hint}</span> : null}
      {error ? <p className="text-[12px] text-danger">{error}</p> : null}
    </div>
  )
}
