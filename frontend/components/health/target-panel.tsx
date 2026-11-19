"use client"

import * as React from "react"
import Link from "next/link"
import { ArrowUpRightIcon, PencilIcon, Trash2Icon, XIcon } from "lucide-react"
import { toast } from "sonner"

import { HealthDot, LatencyChart } from "@/components/health/charts"
import { NONE } from "@/components/health/device-form-dialog"
import { IconButton } from "@/components/shell/icon-button"
import { Chip, LoadingState, Spinner } from "@/components/shell/primitives"
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
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { cameraHref } from "@/components/wall/wall-tile"
import { api, errorMessage } from "@/lib/api"
import {
  DEVICE_KIND_LABELS,
  LINKS,
  LINK_LABELS,
  STATUS_LABELS,
  formatAgo,
  formatLatency,
  formatMoment,
  formatPercent,
  formatSpan,
  viaLine,
} from "@/lib/health"
import type { HealthRange, LinkKind, Outage, TargetDetail, TargetHealth } from "@/lib/types"

function Section({ title, action, children }: { title: string; action?: React.ReactNode; children: React.ReactNode }) {
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

function ReadOut({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex items-baseline justify-between gap-3 text-[12px]">
      <span className="text-text-3">{label}</span>
      <span className="truncate font-data text-foreground">{value}</span>
    </div>
  )
}

function OutageItem({ outage }: { outage: Outage }) {
  return (
    <li className="flex flex-col gap-1 border-b border-hairline py-2.5 last:border-b-0">
      <div className="flex items-center justify-between gap-2">
        <span className="font-data text-[12px] text-foreground">{formatMoment(outage.started_at)}</span>
        {outage.ongoing ? (
          <Chip className="h-5 px-1.5 text-[10px] text-danger">Ongoing</Chip>
        ) : (
          <span className="font-data text-[12px] text-text-2">{formatSpan(outage.duration_seconds)}</span>
        )}
      </div>
      <span className="text-[12px] text-text-3">
        {outage.upstream_name ? `Caused by ${outage.upstream_name}` : "Failed by itself"}
        {outage.ongoing ? `, down for ${formatSpan(outage.duration_seconds)}` : ""}
      </span>
    </li>
  )
}

function CameraLinkForm({
  target,
  devices,
  onSaved,
}: {
  target: TargetHealth
  devices: TargetHealth[]
  onSaved: () => void
}) {
  const [parent, setParent] = React.useState(target.parent_uuid ?? NONE)
  const [link, setLink] = React.useState<string>(target.link ?? "wifi_24")
  const [saving, setSaving] = React.useState(false)
  const changed = (parent === NONE ? null : parent) !== target.parent_uuid || (parent !== NONE && link !== target.link)

  const save = async () => {
    setSaving(true)
    try {
      const parentUuid = parent === NONE ? null : parent
      await api.setCameraLink(target.uuid, { parent_uuid: parentUuid, link: parentUuid ? (link as LinkKind) : null })
      toast.success(parentUuid ? `Saved how ${target.name} connects` : `${target.name} has no upstream device now`)
      onSaved()
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="grid grid-cols-2 gap-3">
        <div className="flex min-w-0 flex-col gap-1.5">
          <Label htmlFor="link-parent">Connected through</Label>
          <Select value={parent} onValueChange={setParent}>
            <SelectTrigger id="link-parent" className="font-mono text-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value={NONE} className="font-mono text-xs">
                Not set
              </SelectItem>
              {devices.map((device) => (
                <SelectItem key={device.uuid} value={device.uuid} className="font-mono text-xs">
                  {device.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className="flex min-w-0 flex-col gap-1.5">
          <Label htmlFor="link-kind">Link</Label>
          <Select value={link} onValueChange={setLink} disabled={parent === NONE}>
            <SelectTrigger id="link-kind" className="font-mono text-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {LINKS.map((value) => (
                <SelectItem key={value} value={value} className="font-mono text-xs">
                  {LINK_LABELS[value]}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>
      <Button variant="outline" size="sm" className="self-start" onClick={save} disabled={!changed || saving}>
        {saving ? <Spinner className="size-3.5" /> : null}
        Save link
      </Button>
    </div>
  )
}

function DeleteDeviceDialog({
  target,
  open,
  onOpenChange,
  onDeleted,
}: {
  target: TargetHealth
  open: boolean
  onOpenChange: (open: boolean) => void
  onDeleted: () => void
}) {
  const [busy, setBusy] = React.useState(false)

  const confirm = async () => {
    setBusy(true)
    try {
      await api.deleteNetworkDevice(target.uuid)
      toast.success(`Deleted ${target.name}`)
      onOpenChange(false)
      onDeleted()
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(false)
    }
  }

  return (
    <AlertDialog open={open} onOpenChange={(value) => !busy && onOpenChange(value)}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete device</AlertDialogTitle>
          <AlertDialogDescription>
            {target.name} stops being probed. Its past outages stay in the log.
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

export function TargetPanel({
  target,
  detail,
  outages,
  devices,
  range,
  now,
  onClose,
  onEdit,
  onChanged,
  onDeleted,
}: {
  target: TargetHealth
  detail: TargetDetail | null
  outages: Outage[] | null
  devices: TargetHealth[]
  range: HealthRange
  now: number
  onClose: () => void
  onEdit: () => void
  onChanged: () => void
  onDeleted: () => void
}) {
  const [deleting, setDeleting] = React.useState(false)
  const live = detail?.target.uuid === target.uuid ? detail.target : target
  const isDevice = live.kind === "device"

  return (
    <div className="flex flex-col" data-testid="health-panel">
      <div className="flex items-start justify-between gap-2 border-b border-hairline px-4 py-3">
        <div className="flex min-w-0 flex-col gap-1">
          <div className="flex min-w-0 items-center gap-2">
            <HealthDot status={live.status} />
            <span className="truncate text-[14px] text-foreground">{live.name}</span>
          </div>
          <span className="truncate font-data text-[11px] text-text-3">
            {isDevice && live.device_kind ? DEVICE_KIND_LABELS[live.device_kind] : "Camera"}, {live.host}:{live.port}
          </span>
        </div>
        <IconButton label="Close" size="icon-sm" onClick={onClose}>
          <XIcon />
        </IconButton>
      </div>
      <Section title="Now">
        <ReadOut label="Status" value={STATUS_LABELS[live.status]} />
        <ReadOut label="Last sample" value={formatAgo(live.last_sample_at, now)} />
        {live.last_error ? <ReadOut label="Last error" value={live.last_error} /> : null}
        <ReadOut label="Upstream" value={viaLine(live)} />
        {live.notes ? <ReadOut label="Notes" value={live.notes} /> : null}
      </Section>
      <Section title="Over the range">
        <ReadOut label="Uptime" value={formatPercent(live.uptime_percent)} />
        <ReadOut label="Samples" value={live.samples.toLocaleString("en-US")} />
        <ReadOut label="Typical latency" value={formatLatency(live.latency.p50_ms)} />
        <ReadOut label="p95 latency" value={formatLatency(live.latency.p95_ms)} />
        <ReadOut label="Average latency" value={formatLatency(live.latency.avg_ms)} />
        <ReadOut label="Slowest answer" value={formatLatency(live.latency.max_ms)} />
        <ReadOut label="Outages" value={live.outage_count} />
      </Section>
      <Section title="Latency">
        {detail && detail.target.uuid === target.uuid ? (
          <LatencyChart buckets={detail.target.buckets} range={range} bucketSeconds={detail.bucket_seconds} />
        ) : (
          <LoadingState label="Loading" className="min-h-36" />
        )}
      </Section>
      <Section title="Outages">
        {outages === null ? (
          <LoadingState label="Loading" className="min-h-20" />
        ) : outages.length === 0 ? (
          <p className="text-[12px] text-text-3">No outages recorded.</p>
        ) : (
          <ul className="-my-2.5 flex flex-col">
            {outages.map((outage) => (
              <OutageItem key={outage.uuid} outage={outage} />
            ))}
          </ul>
        )}
      </Section>
      {isDevice ? (
        <Section title="Device">
          <div className="flex flex-wrap gap-2">
            <Button variant="outline" size="sm" onClick={onEdit}>
              <PencilIcon />
              Edit device
            </Button>
            <Button variant="outline" size="sm" onClick={() => setDeleting(true)}>
              <Trash2Icon />
              Delete
            </Button>
          </div>
          <DeleteDeviceDialog target={live} open={deleting} onOpenChange={setDeleting} onDeleted={onDeleted} />
        </Section>
      ) : (
        <Section
          title="Connection"
          action={
            <Button asChild variant="ghost" size="xs">
              <Link href={cameraHref(live.uuid)}>
                Open camera
                <ArrowUpRightIcon />
              </Link>
            </Button>
          }
        >
          <CameraLinkForm key={`${live.uuid}-${live.parent_uuid}-${live.link}`} target={live} devices={devices} onSaved={onChanged} />
        </Section>
      )}
    </div>
  )
}
