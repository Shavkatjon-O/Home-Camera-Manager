"use client"

import * as React from "react"

import { FEATURE_LABELS, LIMIT_LABELS, featureLabel, limitLabel } from "@/components/business/labels"
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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { errorMessage } from "@/lib/api"
import type { AdminOrganisation, PlanChoice, PlanOverrides } from "@/lib/types"

const INTERNAL_PLAN = "internal"
const PLAN_DEFAULT = "default"

type FeatureChoice = "default" | "on" | "off"

/**
 * Dialog that changes the plan and the overrides of one organisation.
 *
 * @param props - The organisation, the offered plans and the save and close handlers.
 * @returns The dialog.
 */
export function PlanDialog({
  organisation,
  plans,
  onSave,
  onClose,
}: {
  organisation: AdminOrganisation
  plans: PlanChoice[]
  onSave: (plan: string, overrides: PlanOverrides) => Promise<void>
  onClose: () => void
}) {
  const [plan, setPlan] = React.useState(organisation.plan)
  const [limits, setLimits] = React.useState<Record<string, string>>(() =>
    Object.fromEntries(
      Object.keys(LIMIT_LABELS).map((key) => {
        const value = organisation.overrides.limits[key]
        return [key, value === undefined || value === null ? "" : String(value)]
      }),
    ),
  )
  const [limitSet, setLimitSet] = React.useState<Record<string, boolean>>(() =>
    Object.fromEntries(Object.keys(LIMIT_LABELS).map((key) => [key, key in organisation.overrides.limits])),
  )
  const [features, setFeatures] = React.useState<Record<string, FeatureChoice>>(() =>
    Object.fromEntries(
      Object.keys(FEATURE_LABELS).map((key) => {
        const value = organisation.overrides.features[key]
        return [key, value === undefined ? "default" : value ? "on" : "off"]
      }),
    ),
  )
  const [busy, setBusy] = React.useState(false)
  const [error, setError] = React.useState<string | null>(null)

  const choices = plans.filter((item) => item.key !== INTERNAL_PLAN)

  const save = async () => {
    const overrides: PlanOverrides = { limits: {}, features: {} }
    for (const key of Object.keys(LIMIT_LABELS)) {
      if (!limitSet[key]) continue
      const text = limits[key].trim()
      if (text === "") {
        overrides.limits[key] = null
        continue
      }
      const number = Number(text)
      if (!Number.isInteger(number) || number < 0) {
        setError(`${limitLabel(key)} must be a whole number or empty for unlimited`)
        return
      }
      overrides.limits[key] = number
    }
    for (const key of Object.keys(FEATURE_LABELS)) {
      if (features[key] !== "default") overrides.features[key] = features[key] === "on"
    }
    setBusy(true)
    setError(null)
    try {
      await onSave(plan, overrides)
    } catch (err) {
      setError(errorMessage(err))
      setBusy(false)
    }
  }

  return (
    <Dialog open onOpenChange={(open) => (open || busy ? undefined : onClose())}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Plan for {organisation.name}</DialogTitle>
          <DialogDescription>Change the plan, or override single limits and features.</DialogDescription>
        </DialogHeader>
        <DialogBody className="flex flex-col gap-4">
          <label className="flex flex-col gap-1 text-xs text-text-3">
            Plan
            <Select value={plan} onValueChange={setPlan}>
              <SelectTrigger aria-label="Plan">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {choices.map((item) => (
                  <SelectItem key={item.key} value={item.key}>
                    {item.name}
                  </SelectItem>
                ))}
                <SelectItem value={INTERNAL_PLAN}>Internal</SelectItem>
              </SelectContent>
            </Select>
          </label>
          <div className="flex flex-col gap-2">
            <span className="text-xs text-text-3">Limit overrides, empty for unlimited</span>
            {Object.keys(LIMIT_LABELS).map((key) => (
              <div key={key} className="flex items-center gap-2">
                <Select
                  value={limitSet[key] ? "override" : PLAN_DEFAULT}
                  onValueChange={(value) => setLimitSet((current) => ({ ...current, [key]: value === "override" }))}
                >
                  <SelectTrigger aria-label={`${limitLabel(key)} source`} className="w-36">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value={PLAN_DEFAULT}>Plan default</SelectItem>
                    <SelectItem value="override">Override</SelectItem>
                  </SelectContent>
                </Select>
                <span className="min-w-0 flex-1 truncate text-[13px] text-foreground">{limitLabel(key)}</span>
                <Input
                  type="number"
                  min={0}
                  aria-label={`${limitLabel(key)} value`}
                  className="w-24"
                  placeholder="Unlimited"
                  disabled={!limitSet[key]}
                  value={limits[key]}
                  onChange={(event) => setLimits((current) => ({ ...current, [key]: event.target.value }))}
                />
              </div>
            ))}
          </div>
          <div className="flex flex-col gap-2">
            <span className="text-xs text-text-3">Feature overrides</span>
            {Object.keys(FEATURE_LABELS).map((key) => (
              <div key={key} className="flex items-center gap-2">
                <span className="min-w-0 flex-1 truncate text-[13px] text-foreground">{featureLabel(key)}</span>
                <Select
                  value={features[key]}
                  onValueChange={(value) => setFeatures((current) => ({ ...current, [key]: value as FeatureChoice }))}
                >
                  <SelectTrigger aria-label={featureLabel(key)} className="w-36">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="default">Plan default</SelectItem>
                    <SelectItem value="on">On</SelectItem>
                    <SelectItem value="off">Off</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            ))}
          </div>
          {error ? <p className="text-[13px] text-danger">{error}</p> : null}
        </DialogBody>
        <DialogFooter>
          <Button variant="outline" onClick={onClose} disabled={busy}>
            Cancel
          </Button>
          <Button onClick={() => void save()} disabled={busy}>
            {busy ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
            Save plan
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

/**
 * Dialog that suspends an organisation with a reason.
 *
 * @param props - The organisation and the confirm and close handlers.
 * @returns The dialog.
 */
export function SuspendDialog({
  organisation,
  onConfirm,
  onClose,
}: {
  organisation: AdminOrganisation
  onConfirm: (reason: string) => Promise<void>
  onClose: () => void
}) {
  const [reason, setReason] = React.useState("")
  const [busy, setBusy] = React.useState(false)
  const [error, setError] = React.useState<string | null>(null)

  const confirm = async () => {
    const text = reason.trim()
    if (!text) {
      setError("Give a reason")
      return
    }
    setBusy(true)
    setError(null)
    try {
      await onConfirm(text)
    } catch (err) {
      setError(errorMessage(err))
      setBusy(false)
    }
  }

  return (
    <Dialog open onOpenChange={(open) => (open || busy ? undefined : onClose())}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Suspend {organisation.name}</DialogTitle>
          <DialogDescription>Platform admins see the reason. Restore the organisation at any time.</DialogDescription>
        </DialogHeader>
        <DialogBody className="flex flex-col gap-2">
          <label className="flex flex-col gap-1 text-xs text-text-3">
            Reason
            <Input
              value={reason}
              maxLength={200}
              autoFocus
              onChange={(event) => setReason(event.target.value)}
            />
          </label>
          {error ? <p className="text-[13px] text-danger">{error}</p> : null}
        </DialogBody>
        <DialogFooter>
          <Button variant="outline" onClick={onClose} disabled={busy}>
            Cancel
          </Button>
          <Button variant="destructive" onClick={() => void confirm()} disabled={busy}>
            {busy ? <Spinner className="size-3.5 text-white" /> : null}
            Suspend
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
