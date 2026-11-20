"use client"

import * as React from "react"
import { toast } from "sonner"

import { Spinner } from "@/components/shell/primitives"
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import { errorMessage } from "@/lib/api"
import {
  COUNT_LABELS,
  createArea,
  deleteArea,
  resetArea,
  updateArea,
  type Area,
  type AreaInput,
  type CountLine,
  type Crossing,
} from "@/lib/counts"
import { labelName } from "@/lib/events"
import { cn } from "@/lib/utils"

const DEFAULT_RESET = "04:00"
const TIME_PATTERN = /^([01]\d|2[0-3]):[0-5]\d$/

interface FormState {
  name: string
  labels: string[]
  resets: boolean
  resetAt: string
  lines: Record<string, Crossing>
}

type Errors = Partial<Record<"name" | "resetAt" | "lines", string>>

function initialState(area: Area | null): FormState {
  if (!area) return { name: "", labels: [], resets: true, resetAt: DEFAULT_RESET, lines: {} }
  const lines: Record<string, Crossing> = {}
  for (const line of area.lines) lines[line.line_uuid] = line.entering
  return {
    name: area.name,
    labels: area.labels,
    resets: area.reset_at !== null,
    resetAt: area.reset_at ?? DEFAULT_RESET,
    lines,
  }
}

function Field({
  id,
  label,
  error,
  className,
  children,
}: {
  id: string
  label: string
  error?: string
  className?: string
  children: React.ReactNode
}) {
  return (
    <div className={cn("flex min-w-0 flex-col gap-1.5", className)}>
      <Label htmlFor={id}>{label}</Label>
      {children}
      {error ? <p className="text-[12px] text-danger">{error}</p> : null}
    </div>
  )
}

function Toggle({ pressed, onClick, children }: { pressed: boolean; onClick: () => void; children: React.ReactNode }) {
  return (
    <button
      type="button"
      aria-pressed={pressed}
      onClick={onClick}
      className={cn(
        "inline-flex h-7 items-center rounded-md border px-2.5 font-mono text-[11px] transition-colors",
        pressed
          ? "border-hairline-strong bg-surface-3 text-foreground"
          : "border-input text-text-2 hover:border-hairline-strong hover:text-foreground",
      )}
    >
      {children}
    </button>
  )
}

function AreaForm({
  area,
  lines,
  onCancel,
  onSaved,
}: {
  area: Area | null
  lines: CountLine[]
  onCancel: () => void
  onSaved: () => void
}) {
  const [form, setForm] = React.useState<FormState>(() => initialState(area))
  const [errors, setErrors] = React.useState<Errors>({})
  const [formError, setFormError] = React.useState<string | null>(null)
  const [saving, setSaving] = React.useState(false)

  const known = new Set(lines.map((line) => line.uuid))
  const missing = area ? area.lines.filter((line) => !known.has(line.line_uuid)) : []
  const choices = [
    ...lines.map((line) => ({ uuid: line.uuid, name: line.name, view: line.view_name })),
    ...missing.map((line) => ({ uuid: line.line_uuid, name: line.line_name, view: line.view_name })),
  ]

  const update = <K extends keyof FormState>(key: K, value: FormState[K]) => {
    setForm((current) => ({ ...current, [key]: value }))
    if (key in errors) setErrors((current) => ({ ...current, [key]: undefined }))
  }

  const toggleLabel = (label: string) =>
    update("labels", form.labels.includes(label) ? form.labels.filter((item) => item !== label) : [...form.labels, label])

  const toggleLine = (uuid: string) => {
    const next = { ...form.lines }
    if (uuid in next) delete next[uuid]
    else next[uuid] = "in"
    update("lines", next)
  }

  const validate = (): Errors => {
    const next: Errors = {}
    if (!form.name.trim()) next.name = "Enter a name"
    if (form.resets && !TIME_PATTERN.test(form.resetAt)) next.resetAt = "Use a time such as 04:00"
    if (Object.keys(form.lines).length === 0) next.lines = "Choose at least one line"
    return next
  }

  const submit = async (event: React.FormEvent) => {
    event.preventDefault()
    const found = validate()
    setErrors(found)
    if (Object.values(found).some(Boolean)) return
    const body: AreaInput = {
      name: form.name.trim(),
      labels: form.labels,
      reset_at: form.resets ? form.resetAt : null,
      lines: Object.entries(form.lines).map(([line_uuid, entering]) => ({ line_uuid, entering })),
    }
    setFormError(null)
    setSaving(true)
    try {
      const saved = area ? await updateArea(area.uuid, body) : await createArea(body)
      toast.success(area ? `Saved ${saved.name}` : `Added ${saved.name}`)
      onSaved()
    } catch (err) {
      setFormError(errorMessage(err))
    } finally {
      setSaving(false)
    }
  }

  return (
    <form onSubmit={submit} noValidate className="flex min-h-0 flex-1 flex-col">
      <DialogHeader>
        <DialogTitle>{area ? "Edit area" : "Add area"}</DialogTitle>
        <DialogDescription>Occupancy is crossings in minus crossings out since the reset.</DialogDescription>
      </DialogHeader>
      <DialogBody className="flex flex-col gap-4">
        <Field id="area-name" label="Name" error={errors.name}>
          <Input
            id="area-name"
            value={form.name}
            onChange={(event) => update("name", event.target.value)}
            placeholder="House"
            maxLength={100}
            autoFocus
            aria-invalid={Boolean(errors.name)}
          />
        </Field>
        <div className="flex flex-col gap-1.5">
          <Label>Labels</Label>
          <div role="group" aria-label="Labels" className="flex flex-wrap gap-1.5">
            {COUNT_LABELS.map((label) => (
              <Toggle key={label} pressed={form.labels.includes(label)} onClick={() => toggleLabel(label)}>
                {labelName(label)}
              </Toggle>
            ))}
          </div>
          <span className="text-[12px] text-text-3">Leave all off to count every label</span>
        </div>
        <div className="flex flex-col gap-2">
          <div className="flex items-start justify-between gap-3">
            <div className="flex flex-col gap-0.5">
              <Label htmlFor="area-resets" className="text-[13px] text-foreground">
                Reset every day
              </Label>
              <span className="text-[12px] text-text-3">Occupancy restarts from 0 at this time</span>
            </div>
            <Switch id="area-resets" checked={form.resets} onCheckedChange={(value) => update("resets", value)} />
          </div>
          {form.resets ? (
            <Field id="area-reset-at" label="Reset time" error={errors.resetAt}>
              <Input
                id="area-reset-at"
                type="time"
                value={form.resetAt}
                onChange={(event) => update("resetAt", event.target.value)}
                className="w-32 font-data"
                aria-invalid={Boolean(errors.resetAt)}
              />
            </Field>
          ) : null}
        </div>
        <div className="flex flex-col gap-1.5">
          <Label>Bounding lines</Label>
          {choices.length === 0 ? (
            <p className="text-[13px] text-text-3">
              Draw a line on a camera&apos;s analytics view to count crossings
            </p>
          ) : (
            <ul className="flex flex-col gap-1.5">
              {choices.map((line) => {
                const on = line.uuid in form.lines
                return (
                  <li key={line.uuid} className="flex items-center justify-between gap-3">
                    <div className="flex min-w-0 items-center gap-2">
                      <Toggle pressed={on} onClick={() => toggleLine(line.uuid)}>
                        {on ? "Bound" : "Bind"}
                      </Toggle>
                      <div className="flex min-w-0 flex-col">
                        <span className="truncate text-[13px] text-foreground">{line.name}</span>
                        <span className="truncate text-[11px] text-text-3">{line.view}</span>
                      </div>
                    </div>
                    {on ? (
                      <Select
                        value={form.lines[line.uuid]}
                        onValueChange={(value) => update("lines", { ...form.lines, [line.uuid]: value as Crossing })}
                      >
                        <SelectTrigger aria-label={`Crossing that enters through ${line.name}`} className="w-36 font-mono text-xs">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="in" className="font-mono text-xs">
                            In enters
                          </SelectItem>
                          <SelectItem value="out" className="font-mono text-xs">
                            Out enters
                          </SelectItem>
                        </SelectContent>
                      </Select>
                    ) : null}
                  </li>
                )
              })}
            </ul>
          )}
          {errors.lines ? <p className="text-[12px] text-danger">{errors.lines}</p> : null}
        </div>
        {formError ? (
          <p role="alert" className="text-[13px] text-danger">
            {formError}
          </p>
        ) : null}
      </DialogBody>
      <DialogFooter>
        <Button type="button" variant="outline" onClick={onCancel} disabled={saving}>
          Cancel
        </Button>
        <Button type="submit" disabled={saving}>
          {saving ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
          {area ? "Save changes" : "Add area"}
        </Button>
      </DialogFooter>
    </form>
  )
}

export function AreaFormDialog({
  open,
  onOpenChange,
  area,
  lines,
  onSaved,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  area: Area | null
  lines: CountLine[]
  onSaved: () => void
}) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-xl">
        {open ? (
          <AreaForm
            key={area?.uuid ?? "new"}
            area={area}
            lines={lines}
            onCancel={() => onOpenChange(false)}
            onSaved={() => {
              onSaved()
              onOpenChange(false)
            }}
          />
        ) : null}
      </DialogContent>
    </Dialog>
  )
}

function OccupancyForm({ area, onCancel, onSaved }: { area: Area; onCancel: () => void; onSaved: () => void }) {
  const [value, setValue] = React.useState("0")
  const [error, setError] = React.useState<string | null>(null)
  const [saving, setSaving] = React.useState(false)

  const submit = async (event: React.FormEvent) => {
    event.preventDefault()
    const text = value.trim()
    if (!/^\d+$/.test(text)) {
      setError("Use a whole number from 0")
      return
    }
    setError(null)
    setSaving(true)
    try {
      await resetArea(area.uuid, Number(text))
      toast.success(`Set ${area.name} to ${Number(text)}`)
      onSaved()
    } catch (err) {
      setError(errorMessage(err))
    } finally {
      setSaving(false)
    }
  }

  return (
    <form onSubmit={submit} noValidate className="flex min-h-0 flex-1 flex-col">
      <DialogHeader>
        <DialogTitle>Set occupancy</DialogTitle>
        <DialogDescription>{`Counting carries on from this number for ${area.name}.`}</DialogDescription>
      </DialogHeader>
      <DialogBody className="flex flex-col gap-4">
        <Field id="occupancy-value" label="People inside" error={error ?? undefined}>
          <Input
            id="occupancy-value"
            value={value}
            onChange={(event) => setValue(event.target.value)}
            inputMode="numeric"
            className="w-32 font-data"
            autoFocus
            aria-invalid={Boolean(error)}
          />
        </Field>
      </DialogBody>
      <DialogFooter>
        <Button type="button" variant="outline" onClick={onCancel} disabled={saving}>
          Cancel
        </Button>
        <Button type="submit" disabled={saving}>
          {saving ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
          Set occupancy
        </Button>
      </DialogFooter>
    </form>
  )
}

export function OccupancyDialog({
  area,
  onOpenChange,
  onSaved,
}: {
  area: Area | null
  onOpenChange: (open: boolean) => void
  onSaved: () => void
}) {
  return (
    <Dialog open={area !== null} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-sm">
        {area ? (
          <OccupancyForm
            key={area.uuid}
            area={area}
            onCancel={() => onOpenChange(false)}
            onSaved={() => {
              onSaved()
              onOpenChange(false)
            }}
          />
        ) : null}
      </DialogContent>
    </Dialog>
  )
}

export function DeleteAreaDialog({
  area,
  onOpenChange,
  onDeleted,
}: {
  area: Area | null
  onOpenChange: (open: boolean) => void
  onDeleted: () => void
}) {
  const [busy, setBusy] = React.useState(false)

  const confirm = async () => {
    if (!area) return
    setBusy(true)
    try {
      await deleteArea(area.uuid)
      toast.success(`Deleted ${area.name}`)
      onDeleted()
      onOpenChange(false)
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(false)
    }
  }

  return (
    <AlertDialog open={area !== null} onOpenChange={(open) => !busy && onOpenChange(open)}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete area</AlertDialogTitle>
          <AlertDialogDescription>
            {area ? `${area.name} stops counting. Its lines keep counting crossings.` : null}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel asChild>
            <Button variant="outline" disabled={busy}>
              Cancel
            </Button>
          </AlertDialogCancel>
          <Button variant="destructive" onClick={confirm} disabled={busy}>
            {busy ? <Spinner className="size-3.5 text-white" /> : null}
            Delete
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
