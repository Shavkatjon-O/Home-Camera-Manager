"use client"

import * as React from "react"
import { CheckIcon } from "lucide-react"

import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import { labelName } from "@/lib/events"
import { EXTRA_OBJECT_LABELS } from "@/lib/extras"
import { cn } from "@/lib/utils"

export type AnimalsMode = "include" | "record" | "exclude"

export interface ZoneObjectValue {
  left_seconds: number
  taken_seconds: number
  object_labels: string[]
  background: boolean
  animals: AnimalsMode
}

const OBJECT_CHOICES = ["backpack", "handbag", "suitcase", "bicycle", "motorcycle", "car"]

const ANIMAL_OPTIONS: { value: AnimalsMode; label: string }[] = [
  { value: "record", label: "Record without alerts" },
  { value: "include", label: "Record and alert" },
  { value: "exclude", label: "Ignore" },
]

const MINUTES_MAX = 1440

function Note({ children }: { children: React.ReactNode }) {
  return <p className="text-[12px] text-text-3">{children}</p>
}

function choiceName(label: string): string {
  return EXTRA_OBJECT_LABELS[label] ?? labelName(label)
}

function ToggleChip({ pressed, onClick, children }: { pressed: boolean; onClick: () => void; children: React.ReactNode }) {
  return (
    <button
      type="button"
      aria-pressed={pressed}
      onClick={onClick}
      className={cn(
        "inline-flex h-6 items-center gap-1 rounded-md bg-chip px-2 font-data text-[11px] whitespace-nowrap text-text-2 transition-colors hover:text-foreground",
        pressed && "bg-surface-3 text-foreground",
      )}
    >
      {pressed ? <CheckIcon aria-hidden className="size-3" /> : null}
      {children}
    </button>
  )
}

function MinutesRow({
  id,
  label,
  hint,
  seconds,
  onChange,
}: {
  id: string
  label: string
  hint: string
  seconds: number
  onChange: (seconds: number) => void
}) {
  const [draft, setDraft] = React.useState<string | null>(null)
  const current = seconds / 60
  const text = draft ?? String(Number.isInteger(current) ? current : Number(current.toFixed(2)))
  const parsed = Number(text.trim())
  const valid = text.trim() !== "" && Number.isFinite(parsed) && parsed >= 0 && parsed <= MINUTES_MAX

  const commit = () => {
    if (draft === null) return
    if (valid && Math.round(parsed * 60) !== seconds) onChange(Math.round(parsed * 60))
    setDraft(null)
  }

  return (
    <div className="flex flex-col gap-1">
      <div className="flex items-center gap-2 text-[12px] text-text-3">
        <label htmlFor={id} className="min-w-0 flex-1">
          {label}
        </label>
        <Input
          id={id}
          value={text}
          inputMode="decimal"
          autoComplete="off"
          aria-invalid={draft !== null && !valid ? true : undefined}
          onChange={(event) => setDraft(event.target.value)}
          onBlur={commit}
          onKeyDown={(event) => {
            if (event.key === "Enter") commit()
            if (event.key === "Escape") setDraft(null)
          }}
          className="h-8 w-20 font-data"
        />
        <span className="w-14 shrink-0">minutes</span>
      </div>
      {draft !== null && !valid ? (
        <span className="text-[11px] text-danger">A number from 0 to {MINUTES_MAX}</span>
      ) : (
        <Note>{hint}</Note>
      )}
    </div>
  )
}

export function AnimalsField({
  value,
  onChange,
}: {
  value: AnimalsMode
  onChange: (value: AnimalsMode) => void
}) {
  const id = React.useId()
  return (
    <div className="flex flex-col gap-1.5">
      <label htmlFor={id} className="text-[12px] text-text-3">
        Animals
      </label>
      <Select value={value} onValueChange={(next) => onChange(next as AnimalsMode)}>
        <SelectTrigger id={id}>
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          {ANIMAL_OPTIONS.map((option) => (
            <SelectItem key={option.value} value={option.value}>
              {option.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  )
}

export function ZoneObjectFields({
  value,
  onChange,
}: {
  value: ZoneObjectValue
  onChange: (changes: Partial<ZoneObjectValue>) => void
}) {
  const id = React.useId()
  const toggle = (label: string) =>
    onChange({
      object_labels: value.object_labels.includes(label)
        ? value.object_labels.filter((item) => item !== label)
        : [...value.object_labels, label],
    })
  return (
    <div className="flex flex-col gap-3">
      <MinutesRow
        id={`${id}-left`}
        label="Left after"
        hint="Time an object stays before it counts as left. 0 turns it off."
        seconds={value.left_seconds}
        onChange={(left_seconds) => onChange({ left_seconds })}
      />
      <MinutesRow
        id={`${id}-taken`}
        label="Taken after"
        hint="Time an object must have been there before its going counts as taken. 0 turns it off."
        seconds={value.taken_seconds}
        onChange={(taken_seconds) => onChange({ taken_seconds })}
      />
      <div className="flex flex-col gap-1.5">
        <span className="text-[12px] text-text-3">Left and taken objects</span>
        <div role="group" aria-label="Left and taken objects" className="flex flex-wrap gap-1">
          {OBJECT_CHOICES.map((label) => (
            <ToggleChip key={label} pressed={value.object_labels.includes(label)} onClick={() => toggle(label)}>
              {choiceName(label)}
            </ToggleChip>
          ))}
        </div>
        <Note>Backpack, handbag, suitcase, bicycle and motorcycle are watched when none is picked.</Note>
      </div>
      <div className="flex items-center justify-between gap-2 text-[12px]">
        <span className="text-text-3">Also find unknown objects by comparing with the empty scene</span>
        <Switch
          aria-label="Also find unknown objects by comparing with the empty scene"
          checked={value.background}
          onCheckedChange={(background) => onChange({ background })}
        />
      </div>
      <AnimalsField value={value.animals} onChange={(animals) => onChange({ animals })} />
    </div>
  )
}
