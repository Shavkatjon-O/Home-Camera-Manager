"use client"

import * as React from "react"
import Link from "next/link"
import { ArrowUpRightIcon, CircleAlertIcon, PlusIcon, RadarIcon } from "lucide-react"

import { CameraFormDialog, type CameraPrefill } from "@/components/cameras/camera-form-dialog"
import { AppFrame } from "@/components/shell/app-frame"
import { Chip, EmptyState, LoadingState, Spinner } from "@/components/shell/primitives"
import { useSession } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { cameraHref } from "@/components/wall/wall-tile"
import { api, errorMessage } from "@/lib/api"
import { brandLabel } from "@/lib/brands"
import { formatDuration, formatTime } from "@/lib/format"
import type { Camera, ScanItem, ScanResult } from "@/lib/types"

export function DiscoverView() {
  const { refresh: refreshSession } = useSession()
  const [subnet, setSubnet] = React.useState("")
  const [scanning, setScanning] = React.useState(false)
  const [result, setResult] = React.useState<ScanResult | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const [prefill, setPrefill] = React.useState<CameraPrefill | null>(null)

  const scan = async (event: React.FormEvent) => {
    event.preventDefault()
    setScanning(true)
    setError(null)
    try {
      setResult(await api.scan(subnet.trim() || undefined))
    } catch (err) {
      setError(errorMessage(err))
    } finally {
      setScanning(false)
    }
  }

  const openAdd = (item: ScanItem) => {
    setPrefill({
      host: item.host,
      brand: item.brand,
      onvif_port: item.onvif_port,
      name: item.model ?? "",
    })
  }

  const added = (camera: Camera) => {
    setResult((current) =>
      current
        ? {
            ...current,
            items: current.items.map((item) =>
              item.host === camera.host ? { ...item, camera_uuid: camera.uuid } : item,
            ),
          }
        : current,
    )
    void refreshSession()
  }

  let body: React.ReactNode
  if (scanning && !result) {
    body = <LoadingState label="Scanning the network" />
  } else if (error && !result) {
    body = (
      <EmptyState icon={<CircleAlertIcon />} title="Scan failed">
        <span className="font-data text-xs">{error}</span>
      </EmptyState>
    )
  } else if (!result) {
    body = (
      <EmptyState icon={<RadarIcon />} title="Find cameras on the network">
        <span>
          The scan sweeps the subnet for RTSP and ONVIF ports and asks each device who it is. It takes a few
          seconds.
        </span>
      </EmptyState>
    )
  } else if (result.items.length === 0) {
    body = (
      <EmptyState icon={<RadarIcon />} title="No cameras found">
        <span>
          Nothing on <span className="font-data">{result.subnet}</span> answered on a camera port.
        </span>
      </EmptyState>
    )
  } else {
    body = (
      <Table>
        <TableHeader>
          <TableRow className="hover:bg-transparent">
            <TableHead>Host</TableHead>
            <TableHead>Open ports</TableHead>
            <TableHead>Brand guess</TableHead>
            <TableHead>Manufacturer and model</TableHead>
            <TableHead className="text-right">Registered</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {result.items.map((item) => (
            <TableRow key={item.host}>
              <TableCell className="font-data text-xs text-foreground">{item.host}</TableCell>
              <TableCell className="font-data text-xs text-text-2">{item.open_ports.join(", ") || "-"}</TableCell>
              <TableCell className="font-data text-xs text-text-2">{brandLabel(item.brand)}</TableCell>
              <TableCell className="max-w-72 truncate text-text-2">
                {[item.manufacturer, item.model].filter(Boolean).join(", ") || "-"}
              </TableCell>
              <TableCell className="text-right">
                {item.camera_uuid ? (
                  <Button asChild variant="ghost" size="xs">
                    <Link href={cameraHref(item.camera_uuid)}>
                      Registered
                      <ArrowUpRightIcon />
                    </Link>
                  </Button>
                ) : (
                  <Button variant="outline" size="xs" onClick={() => openAdd(item)}>
                    <PlusIcon />
                    Add
                  </Button>
                )}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    )
  }

  return (
    <AppFrame
      status={
        result ? (
          <Chip>
            {result.items.length} found in {formatDuration(result.duration_ms)}
          </Chip>
        ) : null
      }
    >
      <main className="flex min-h-0 min-w-0 flex-1 flex-col">
        <form
          onSubmit={scan}
          className="flex shrink-0 flex-wrap items-center gap-2 border-b border-hairline px-3 py-3 sm:px-4"
        >
          <Input
            aria-label="Subnet"
            value={subnet}
            onChange={(event) => setSubnet(event.target.value)}
            placeholder="Server default, for example 192.168.1.0/24"
            className="h-8 w-full max-w-sm font-data"
            spellCheck={false}
            autoComplete="off"
          />
          <Button type="submit" disabled={scanning}>
            {scanning ? <Spinner className="size-3.5 text-primary-foreground" /> : <RadarIcon />}
            {scanning ? "Scanning" : "Scan network"}
          </Button>
          {result ? (
            <span className="font-data text-[11px] text-text-3">
              {result.subnet} at {formatTime(result.scanned_at)}
            </span>
          ) : null}
          {error && result ? <span className="text-[12px] text-danger">{error}</span> : null}
        </form>
        <div className="min-h-0 flex-1 overflow-auto">{body}</div>
      </main>
      <CameraFormDialog
        open={prefill !== null}
        onOpenChange={(open) => {
          if (!open) setPrefill(null)
        }}
        prefill={prefill}
        onSaved={added}
      />
    </AppFrame>
  )
}
