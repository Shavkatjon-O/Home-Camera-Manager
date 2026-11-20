"use client"

import * as React from "react"
import Link from "next/link"
import {
  ArrowUpRightIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  CircleAlertIcon,
  CctvOffIcon,
  PencilIcon,
  PlusIcon,
  Trash2Icon,
} from "lucide-react"

import { CameraFormDialog } from "@/components/cameras/camera-form-dialog"
import { DeleteCameraDialog } from "@/components/cameras/delete-camera-dialog"
import { WallOrder } from "@/components/cameras/wall-order"
import { PageFrame } from "@/components/shell/page-frame"
import { IconButton } from "@/components/shell/icon-button"
import { Chip, EmptyState, LoadingState, StatusDot } from "@/components/shell/primitives"
import { useCan, useSession } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { cameraHref } from "@/components/wall/wall-tile"
import { api, errorMessage, isAbort } from "@/lib/api"
import { brandLabel } from "@/lib/brands"
import { formatDateTime, statusLabel } from "@/lib/format"
import type { Camera, Page } from "@/lib/types"

const PAGE_SIZE = 20

/** The Cameras page: every camera of the site in a table, and their order on the wall. */
export function CamerasView() {
  const { refresh: refreshSession } = useSession()
  const canManage = useCan("admin")
  const [page, setPage] = React.useState(1)
  const [reload, setReload] = React.useState(0)
  const [data, setData] = React.useState<Page<Camera> | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const [formOpen, setFormOpen] = React.useState(false)
  const [editing, setEditing] = React.useState<Camera | null>(null)
  const [deleting, setDeleting] = React.useState<Camera | null>(null)

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .listCameras({ order: "created", page, page_size: PAGE_SIZE }, controller.signal)
      .then((result) => {
        if (result.items.length === 0 && result.total > 0 && page > 1) {
          setPage(Math.max(1, Math.ceil(result.total / PAGE_SIZE)))
          return
        }
        setData(result)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(errorMessage(err))
      })
    return () => controller.abort()
  }, [page, reload])

  const changed = () => {
    setReload((value) => value + 1)
    void refreshSession()
  }

  const openAdd = () => {
    setEditing(null)
    setFormOpen(true)
  }

  const openEdit = (camera: Camera) => {
    setEditing(camera)
    setFormOpen(true)
  }

  const total = data?.total ?? 0
  const pageCount = Math.max(1, Math.ceil(total / PAGE_SIZE))
  const first = total === 0 ? 0 : (page - 1) * PAGE_SIZE + 1
  const last = Math.min(page * PAGE_SIZE, total)

  const actions = canManage ? (
    <Button onClick={openAdd}>
      <PlusIcon />
      <span className="hidden sm:inline">Add camera</span>
      <span className="sm:hidden">Add</span>
    </Button>
  ) : null

  let content: React.ReactNode
  if (!data && error) {
    content = (
      <EmptyState icon={<CircleAlertIcon />} title="Cannot load cameras">
        <span className="font-data text-xs">{error}</span>
        <Button variant="outline" onClick={() => setReload((value) => value + 1)}>
          Try again
        </Button>
      </EmptyState>
    )
  } else if (!data) {
    content = <LoadingState label="Loading cameras" />
  } else if (data.total === 0) {
    content = (
      <EmptyState icon={<CctvOffIcon />} title="No cameras yet">
        {canManage ? (
          <>
            <span>Add one by hand, or scan the network and add what it finds.</span>
            <Button asChild variant="outline">
              <Link href="/discover/">Scan the network</Link>
            </Button>
          </>
        ) : (
          <span>An admin of this site adds its cameras.</span>
        )}
      </EmptyState>
    )
  } else {
    content = (
      <div className="flex flex-col">
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent">
              <TableHead>Name</TableHead>
              <TableHead>Brand</TableHead>
              <TableHead>Host</TableHead>
              <TableHead>Location</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>PTZ</TableHead>
              <TableHead>Created</TableHead>
              <TableHead>Updated</TableHead>
              <TableHead className="w-0 text-right">
                <span className="sr-only">Actions</span>
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.items.map((camera) => (
              <TableRow key={camera.uuid}>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Link href={cameraHref(camera.uuid)} className="max-w-56 truncate text-foreground hover:underline">
                      {camera.name}
                    </Link>
                    {!camera.enabled ? <Chip>Disabled</Chip> : null}
                  </div>
                </TableCell>
                <TableCell className="font-data text-xs text-text-2">{brandLabel(camera.brand)}</TableCell>
                <TableCell className="font-data text-xs text-text-2">
                  {camera.host}:{camera.rtsp_port}
                </TableCell>
                <TableCell className="max-w-48 truncate text-text-2">{camera.location ?? "-"}</TableCell>
                <TableCell>
                  <span
                    className="inline-flex items-center gap-2 text-text-2"
                    title={camera.status.error ?? undefined}
                  >
                    <StatusDot online={camera.status.online} />
                    {statusLabel(camera.status.online)}
                  </span>
                </TableCell>
                <TableCell className="text-text-2">{camera.ptz_enabled ? "Yes" : "No"}</TableCell>
                <TableCell className="font-data text-xs text-text-2">{formatDateTime(camera.created_at)}</TableCell>
                <TableCell className="font-data text-xs text-text-2">{formatDateTime(camera.updated_at)}</TableCell>
                <TableCell className="text-right">
                  <div className="flex items-center justify-end gap-0.5">
                    <IconButton asChild label="Open" size="icon-sm">
                      <Link href={cameraHref(camera.uuid)}>
                        <ArrowUpRightIcon />
                      </Link>
                    </IconButton>
                    {canManage ? (
                      <IconButton label="Edit" size="icon-sm" onClick={() => openEdit(camera)}>
                        <PencilIcon />
                      </IconButton>
                    ) : null}
                    {canManage ? (
                      <IconButton label="Delete" size="icon-sm" onClick={() => setDeleting(camera)}>
                        <Trash2Icon />
                      </IconButton>
                    ) : null}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <div className="flex items-center justify-between gap-3 px-3 py-3">
          <span className="font-data text-[11px] text-text-3">
            {first} to {last} of {total}
            {error ? <span className="ml-3 text-danger">{error}</span> : null}
          </span>
          <div className="flex items-center gap-1">
            <IconButton
              label="Previous page"
              variant="outline"
              size="icon-sm"
              side="top"
              disabled={page <= 1}
              onClick={() => setPage((value) => Math.max(1, value - 1))}
            >
              <ChevronLeftIcon />
            </IconButton>
            <IconButton
              label="Next page"
              variant="outline"
              size="icon-sm"
              side="top"
              disabled={page >= pageCount}
              onClick={() => setPage((value) => value + 1)}
            >
              <ChevronRightIcon />
            </IconButton>
          </div>
        </div>
      </div>
    )
  }

  return (
    <PageFrame actions={actions}>
      <div className="flex min-h-0 min-w-0 flex-1 flex-col overflow-auto lg:flex-row lg:overflow-hidden">
        <main className="min-w-0 shrink-0 lg:min-h-0 lg:flex-1 lg:overflow-auto">{content}</main>
        <aside className="shrink-0 border-t border-hairline lg:w-[300px] lg:overflow-y-auto lg:border-t-0 lg:border-l">
          <WallOrder />
        </aside>
      </div>
      <CameraFormDialog
        open={formOpen}
        onOpenChange={setFormOpen}
        camera={editing}
        onSaved={() => {
          if (!editing) setPage(1)
          changed()
        }}
      />
      <DeleteCameraDialog
        camera={deleting}
        onOpenChange={(open) => {
          if (!open) setDeleting(null)
        }}
        onDeleted={() => changed()}
      />
    </PageFrame>
  )
}
