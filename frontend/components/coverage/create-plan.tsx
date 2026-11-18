"use client"

import * as React from "react"
import { toast } from "sonner"

import { Spinner } from "@/components/shell/primitives"
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
import { api, errorMessage } from "@/lib/api"
import { PLAN_HEIGHT_DEFAULT_M, PLAN_SIZE_MAX_M, PLAN_SIZE_MIN_M, PLAN_WIDTH_DEFAULT_M } from "@/lib/plan-edit"
import type { FloorPlan } from "@/lib/types"
import { cn } from "@/lib/utils"

const NAME_MAX = 100

function useCreatePlan(onCreated: (plan: FloorPlan) => void) {
  const [name, setName] = React.useState("Home")
  const [width, setWidth] = React.useState(String(PLAN_WIDTH_DEFAULT_M))
  const [busy, setBusy] = React.useState(false)
  const [touched, setTouched] = React.useState(false)

  const widthValue = Number(width.trim())
  const nameError = name.trim() === "" ? "Enter a name" : null
  const widthError =
    width.trim() === "" || !Number.isFinite(widthValue) || widthValue < PLAN_SIZE_MIN_M || widthValue > PLAN_SIZE_MAX_M
      ? `From ${PLAN_SIZE_MIN_M} to ${PLAN_SIZE_MAX_M} m`
      : null

  const submit = async (event: React.FormEvent) => {
    event.preventDefault()
    setTouched(true)
    if (nameError || widthError) return
    setBusy(true)
    try {
      const plan = await api.createFloorPlan({
        name: name.trim(),
        width_m: widthValue,
        height_m: PLAN_HEIGHT_DEFAULT_M,
      })
      toast.success(`Created ${plan.name}`)
      onCreated(plan)
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(false)
    }
  }

  return {
    name,
    setName,
    width,
    setWidth,
    busy,
    submit,
    nameError: touched ? nameError : null,
    widthError: touched ? widthError : null,
  }
}

function CreateFields({ form, prefix }: { form: ReturnType<typeof useCreatePlan>; prefix: string }) {
  return (
    <div className="grid grid-cols-[1fr_8rem] gap-3 text-left">
      <div className="flex min-w-0 flex-col gap-1.5">
        <Label htmlFor={`${prefix}-name`}>Name</Label>
        <Input
          id={`${prefix}-name`}
          value={form.name}
          maxLength={NAME_MAX}
          autoComplete="off"
          aria-invalid={form.nameError ? true : undefined}
          onChange={(event) => form.setName(event.target.value)}
        />
        {form.nameError ? <span className="text-[11px] text-danger">{form.nameError}</span> : null}
      </div>
      <div className="flex min-w-0 flex-col gap-1.5">
        <Label htmlFor={`${prefix}-width`}>Rough width</Label>
        <div className="relative">
          <Input
            id={`${prefix}-width`}
            inputMode="decimal"
            autoComplete="off"
            value={form.width}
            aria-invalid={form.widthError ? true : undefined}
            onChange={(event) => form.setWidth(event.target.value)}
            className="pr-7 font-data"
          />
          <span className="pointer-events-none absolute inset-y-0 right-2.5 flex items-center font-data text-[11px] text-text-3">
            m
          </span>
        </div>
        {form.widthError ? <span className="text-[11px] text-danger">{form.widthError}</span> : null}
      </div>
    </div>
  )
}

export function CreatePlanForm({ onCreated, className }: { onCreated: (plan: FloorPlan) => void; className?: string }) {
  const form = useCreatePlan(onCreated)
  return (
    <form onSubmit={form.submit} className={cn("flex w-full max-w-sm flex-col gap-4", className)}>
      <CreateFields form={form} prefix="empty-plan" />
      <Button type="submit" disabled={form.busy} className="self-center">
        {form.busy ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
        Create plan
      </Button>
    </form>
  )
}

export function CreatePlanDialog({
  open,
  onOpenChange,
  onCreated,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  onCreated: (plan: FloorPlan) => void
}) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md">
        {open ? (
          <CreateDialogBody
            onCreated={(plan) => {
              onOpenChange(false)
              onCreated(plan)
            }}
            onCancel={() => onOpenChange(false)}
          />
        ) : null}
      </DialogContent>
    </Dialog>
  )
}

function CreateDialogBody({ onCreated, onCancel }: { onCreated: (plan: FloorPlan) => void; onCancel: () => void }) {
  const form = useCreatePlan(onCreated)
  return (
    <form onSubmit={form.submit} className="flex min-h-0 flex-col">
      <DialogHeader>
        <DialogTitle>New plan</DialogTitle>
        <DialogDescription>
          A rough width is enough. The height starts at {PLAN_HEIGHT_DEFAULT_M} m and follows a background image once you
          add one.
        </DialogDescription>
      </DialogHeader>
      <DialogBody>
        <CreateFields form={form} prefix="new-plan" />
      </DialogBody>
      <DialogFooter>
        <Button type="button" variant="outline" onClick={onCancel} disabled={form.busy}>
          Cancel
        </Button>
        <Button type="submit" disabled={form.busy}>
          {form.busy ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
          Create plan
        </Button>
      </DialogFooter>
    </form>
  )
}
