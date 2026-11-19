import * as React from "react"

import { StatusDot } from "@/components/shell/primitives"
import { brandLabel } from "@/lib/brands"
import { formatDateTime, formatTime, statusLabel } from "@/lib/format"
import type { Camera } from "@/lib/types"

function Row({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="grid grid-cols-[96px_minmax(0,1fr)] items-baseline gap-3 py-1.5">
      <dt className="text-xs text-text-3">{label}</dt>
      <dd className="min-w-0 font-data text-xs break-all text-foreground">{children}</dd>
    </div>
  )
}

export function CameraDetails({ camera }: { camera: Camera }) {
  return (
    <dl className="flex flex-col">
      <Row label="Status">
        <span className="inline-flex items-center gap-2 font-sans">
          <StatusDot online={camera.status.online} />
          {statusLabel(camera.status.online)}
        </span>
      </Row>
      <Row label="Checked">{formatTime(camera.status.checked_at)}</Row>
      {camera.status.error ? (
        <Row label="Error">
          <span className="text-danger">{camera.status.error}</span>
        </Row>
      ) : null}
      <Row label="Brand">{brandLabel(camera.brand)}</Row>
      <Row label="Host">{camera.host}</Row>
      <Row label="Device address">{camera.device_host ?? "-"}</Row>
      <Row label="RTSP port">{camera.rtsp_port}</Row>
      <Row label="ONVIF port">{camera.onvif_port ?? "-"}</Row>
      <Row label="Username">{camera.username ?? "-"}</Row>
      <Row label="Password">
        <span className="font-sans">{camera.has_password ? "Saved" : "None"}</span>
      </Row>
      <Row label="Main path">{camera.main_path}</Row>
      <Row label="Sub path">{camera.sub_path ?? "-"}</Row>
      <Row label="Lenses">{camera.lenses}</Row>
      <Row label="Location">
        <span className="font-sans">{camera.location ?? "-"}</span>
      </Row>
      <Row label="PTZ">
        <span className="font-sans">{camera.ptz_enabled ? "Yes" : "No"}</span>
      </Row>
      <Row label="Wall">
        <span className="font-sans">{camera.enabled ? `Position ${camera.position}` : "Disabled"}</span>
      </Row>
      <Row label="Created">{formatDateTime(camera.created_at)}</Row>
      <Row label="Updated">{formatDateTime(camera.updated_at)}</Row>
    </dl>
  )
}
