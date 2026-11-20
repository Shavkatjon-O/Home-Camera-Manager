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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import { api, errorMessage } from "@/lib/api"
import { DEVICE_KINDS, DEVICE_KIND_LABELS, LINKS, LINK_LABELS } from "@/lib/health"
import type { DeviceKind, LinkKind, NetworkDeviceCreate, NetworkDeviceUpdate, TargetHealth } from "@/lib/types"
import { cn } from "@/lib/utils"

/** The select value that stands for no upstream device. */
export const NONE = "none"

const HOST_PATTERN = /^[A-Za-z0-9._-]+$/

interface FormState {
  name: string
  kind: DeviceKind
  host: string
  port: string
  parent: string
  link: string
  notes: string
  enabled: boolean
}

type Errors = Partial<Record<"name" | "host" | "port", string>>

function initialState(device: TargetHealth | null): FormState {
  if (device) {
    return {
      name: device.name,
      kind: device.device_kind ?? "other",
      host: device.host,
      port: String(device.port),
      parent: device.parent_uuid ?? NONE,
      link: device.link ?? NONE,
      notes: device.notes ?? "",
      enabled: device.enabled,
    }
  }
  return { name: "", kind: "router", host: "", port: "80", parent: NONE, link: NONE, notes: "", enabled: true }
}

/** The devices that sit behind a device, itself included, so it cannot be chosen as their own upstream. */
export function behind(devices: TargetHealth[], uuid: string): Set<string> {
  const blocked = new Set([uuid])
  let grew = true
  while (grew) {
    grew = false
    for (const device of devices) {
      if (device.parent_uuid && blocked.has(device.parent_uuid) && !blocked.has(device.uuid)) {
        blocked.add(device.uuid)
        grew = true
      }
    }
  }
  return blocked
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

function DeviceForm({
  device,
  devices,
  onCancel,
  onSaved,
}: {
  device: TargetHealth | null
  devices: TargetHealth[]
  onCancel: () => void
  onSaved: () => void
}) {
  const [form, setForm] = React.useState<FormState>(() => initialState(device))
  const [errors, setErrors] = React.useState<Errors>({})
  const [formError, setFormError] = React.useState<string | null>(null)
  const [saving, setSaving] = React.useState(false)

  const blocked = device ? behind(devices, device.uuid) : new Set<string>()
  const parents = devices.filter((item) => !blocked.has(item.uuid))

  const update = <K extends keyof FormState>(key: K, value: FormState[K]) => {
    setForm((current) => ({ ...current, [key]: value }))
    if (key in errors) setErrors((current) => ({ ...current, [key]: undefined }))
  }

  const validate = (): Errors => {
    const next: Errors = {}
    if (!form.name.trim()) next.name = "Enter a name"
    if (!form.host.trim()) next.host = "Enter the address"
    else if (!HOST_PATTERN.test(form.host.trim())) next.host = "Use an IP address or a host name"
    const port = Number(form.port.trim())
    if (!/^\d+$/.test(form.port.trim()) || port < 1 || port > 65535) next.port = "Use a port from 1 to 65535"
    return next
  }

  const body = (): NetworkDeviceCreate => {
    const parent = form.parent === NONE ? null : form.parent
    return {
      name: form.name.trim(),
      kind: form.kind,
      host: form.host.trim(),
      probe_port: Number(form.port.trim()),
      parent_uuid: parent,
      link: parent && form.link !== NONE ? (form.link as LinkKind) : null,
      notes: form.notes.trim() || null,
      enabled: form.enabled,
    }
  }

  const changes = (original: TargetHealth, next: NetworkDeviceCreate): NetworkDeviceUpdate => {
    const result: NetworkDeviceUpdate = {}
    if (next.name !== original.name) result.name = next.name
    if (next.kind !== original.device_kind) result.kind = next.kind
    if (next.host !== original.host) result.host = next.host
    if (next.probe_port !== original.port) result.probe_port = next.probe_port
    if (next.parent_uuid !== original.parent_uuid) result.parent_uuid = next.parent_uuid
    if (next.link !== original.link) result.link = next.link
    if (next.notes !== original.notes) result.notes = next.notes
    if (next.enabled !== original.enabled) result.enabled = next.enabled
    return result
  }

  const submit = async (event: React.FormEvent) => {
    event.preventDefault()
    const found = validate()
    setErrors(found)
    if (Object.values(found).some(Boolean)) return
    setFormError(null)
    setSaving(true)
    try {
      if (device) {
        const patch = changes(device, body())
        if (Object.keys(patch).length === 0) {
          onCancel()
          return
        }
        const saved = await api.updateNetworkDevice(device.uuid, patch)
        toast.success(`Saved ${saved.name}`)
      } else {
        const saved = await api.createNetworkDevice(body())
        toast.success(`Added ${saved.name}`)
      }
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
        <DialogTitle>{device ? "Edit network device" : "Add network device"}</DialogTitle>
        <DialogDescription>
          A router, access point or repeater the cameras connect through. Its address is checked over TCP every few
          seconds.
        </DialogDescription>
      </DialogHeader>
      <DialogBody className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Field id="device-name" label="Name" error={errors.name}>
          <Input
            id="device-name"
            value={form.name}
            onChange={(event) => update("name", event.target.value)}
            placeholder="Archer C64"
            maxLength={100}
            autoFocus
            aria-invalid={Boolean(errors.name)}
          />
        </Field>
        <Field id="device-kind" label="Kind">
          <Select value={form.kind} onValueChange={(value) => update("kind", value as DeviceKind)}>
            <SelectTrigger id="device-kind" className="font-mono text-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {DEVICE_KINDS.map((kind) => (
                <SelectItem key={kind} value={kind} className="font-mono text-xs">
                  {DEVICE_KIND_LABELS[kind]}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </Field>
        <Field id="device-host" label="Address" error={errors.host}>
          <Input
            id="device-host"
            value={form.host}
            onChange={(event) => update("host", event.target.value)}
            placeholder="192.168.1.1"
            className="font-data"
            maxLength={255}
            autoComplete="off"
            spellCheck={false}
            aria-invalid={Boolean(errors.host)}
          />
        </Field>
        <Field id="device-port" label="Probe port" error={errors.port}>
          <Input
            id="device-port"
            value={form.port}
            onChange={(event) => update("port", event.target.value)}
            placeholder="80"
            inputMode="numeric"
            className="font-data"
            aria-invalid={Boolean(errors.port)}
          />
        </Field>
        <Field id="device-parent" label="Connected through">
          <Select value={form.parent} onValueChange={(value) => update("parent", value)}>
            <SelectTrigger id="device-parent" className="font-mono text-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value={NONE} className="font-mono text-xs">
                Nothing, top of the network
              </SelectItem>
              {parents.map((item) => (
                <SelectItem key={item.uuid} value={item.uuid} className="font-mono text-xs">
                  {item.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </Field>
        <Field id="device-link" label="Link">
          <Select
            value={form.parent === NONE ? NONE : form.link}
            onValueChange={(value) => update("link", value)}
            disabled={form.parent === NONE}
          >
            <SelectTrigger id="device-link" className="font-mono text-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value={NONE} className="font-mono text-xs">
                Not set
              </SelectItem>
              {LINKS.map((link) => (
                <SelectItem key={link} value={link} className="font-mono text-xs">
                  {LINK_LABELS[link]}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </Field>
        <Field id="device-notes" label="Notes" className="sm:col-span-2">
          <Input
            id="device-notes"
            value={form.notes}
            onChange={(event) => update("notes", event.target.value)}
            placeholder="Optional"
            maxLength={1000}
          />
        </Field>
        <div className="flex items-start justify-between gap-3 sm:col-span-2">
          <div className="flex flex-col gap-0.5">
            <Label htmlFor="device-enabled" className="text-[13px] text-foreground">
              Enabled
            </Label>
            <span className="text-[12px] text-text-3">Probed and counted in the health summary</span>
          </div>
          <Switch id="device-enabled" checked={form.enabled} onCheckedChange={(value) => update("enabled", value)} />
        </div>
        {formError ? (
          <p role="alert" className="text-[13px] text-danger sm:col-span-2">
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
          {device ? "Save changes" : "Add network device"}
        </Button>
      </DialogFooter>
    </form>
  )
}

/** The dialog that adds a network device to watch or edits one. */
export function DeviceFormDialog({
  open,
  onOpenChange,
  device,
  devices,
  onSaved,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  device: TargetHealth | null
  devices: TargetHealth[]
  onSaved: () => void
}) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-xl">
        {open ? (
          <DeviceForm
            key={device?.uuid ?? "new"}
            device={device}
            devices={devices}
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
