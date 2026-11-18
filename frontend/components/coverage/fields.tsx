"use client"

import * as React from "react"

import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { cn } from "@/lib/utils"

export function Section({
  title,
  action,
  children,
}: {
  title: string
  action?: React.ReactNode
  children: React.ReactNode
}) {
  return (
    <section className="flex flex-col gap-3 border-b border-hairline px-4 py-4 last:border-b-0">
      <div className="flex min-h-5 items-center justify-between gap-2">
        <h2 className="text-xs text-text-3">{title}</h2>
        {action}
      </div>
      {children}
    </section>
  )
}

export function FieldRow({ children, className }: { children: React.ReactNode; className?: string }) {
  return <div className={cn("grid grid-cols-2 gap-3", className)}>{children}</div>
}

export function ReadOut({ label, value, className }: { label: string; value: React.ReactNode; className?: string }) {
  return (
    <div className={cn("flex items-baseline justify-between gap-3 text-[12px]", className)}>
      <span className="text-text-3">{label}</span>
      <span className="font-data text-foreground">{value}</span>
    </div>
  )
}

export function NumberField({
  id,
  label,
  value,
  min,
  max,
  unit,
  disabled,
  validate,
  onCommit,
}: {
  id: string
  label: string
  value: number
  min: number
  max: number
  unit?: string
  disabled?: boolean
  validate?: (value: number) => string | null
  onCommit: (value: number) => void
}) {
  const [draft, setDraft] = React.useState<string | null>(null)
  const text = draft ?? String(value)
  const parsed = Number(text.trim())
  let error: string | null = null
  if (draft !== null) {
    if (text.trim() === "" || !Number.isFinite(parsed)) error = "Enter a number"
    else if (parsed < min || parsed > max) error = `From ${min} to ${max}`
    else if (validate) error = validate(parsed)
  }

  const commit = () => {
    if (draft === null) return
    if (!error && parsed !== value) onCommit(parsed)
    setDraft(null)
  }

  return (
    <div className="flex min-w-0 flex-col gap-1.5">
      <Label htmlFor={id}>{label}</Label>
      <div className="relative">
        <Input
          id={id}
          inputMode="decimal"
          autoComplete="off"
          value={text}
          disabled={disabled}
          aria-invalid={error ? true : undefined}
          onChange={(event) => setDraft(event.target.value)}
          onBlur={commit}
          onKeyDown={(event) => {
            if (event.key === "Enter") commit()
            if (event.key === "Escape") setDraft(null)
          }}
          className={cn("font-data", unit && "pr-11")}
        />
        {unit ? (
          <span className="pointer-events-none absolute inset-y-0 right-2.5 flex items-center font-data text-[11px] text-text-3">
            {unit}
          </span>
        ) : null}
      </div>
      {error ? <span className="text-[11px] text-danger">{error}</span> : null}
    </div>
  )
}

export function TextField({
  id,
  label,
  value,
  maxLength,
  onCommit,
}: {
  id: string
  label: string
  value: string
  maxLength: number
  onCommit: (value: string) => void
}) {
  const [draft, setDraft] = React.useState<string | null>(null)
  const text = draft ?? value
  const error = draft !== null && text.trim() === "" ? "Enter a name" : null

  const commit = () => {
    if (draft === null) return
    const next = text.trim()
    if (next && next !== value) onCommit(next)
    setDraft(null)
  }

  return (
    <div className="flex min-w-0 flex-col gap-1.5">
      <Label htmlFor={id}>{label}</Label>
      <Input
        id={id}
        value={text}
        maxLength={maxLength}
        autoComplete="off"
        aria-invalid={error ? true : undefined}
        onChange={(event) => setDraft(event.target.value)}
        onBlur={commit}
        onKeyDown={(event) => {
          if (event.key === "Enter") commit()
          if (event.key === "Escape") setDraft(null)
        }}
      />
      {error ? <span className="text-[11px] text-danger">{error}</span> : null}
    </div>
  )
}
