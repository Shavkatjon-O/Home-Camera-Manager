"use client"

import * as React from "react"
import { CircleAlertIcon, PencilIcon, PlusIcon, Trash2Icon } from "lucide-react"
import { toast } from "sonner"

import { IconButton } from "@/components/shell/icon-button"
import { EmptyState, LoadingState, Spinner } from "@/components/shell/primitives"
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
import { Input } from "@/components/ui/input"
import { errorMessage } from "@/lib/api"
import type { PlanDoc } from "@/lib/plan-edit"
import type { FloorPlanSummary } from "@/lib/types"
import { cn } from "@/lib/utils"

const NAME_MAX = 100

export interface PlanListProps {
  plans: FloorPlanSummary[]
  total: number
  activeUuid: string | null
  loading: boolean
  error: string | null
  loadingMore: boolean
  onSelect: (uuid: string) => void
  onCreate: () => void
  onRename: (uuid: string, name: string) => Promise<void>
  onDelete: (plan: FloorPlanSummary) => Promise<void>
  onLoadMore: () => void
  onRetry: () => void
}

function formatSize(value: number): string {
  return String(Math.round(value * 100) / 100)
}

function plural(count: number, word: string): string {
  return `${count} ${word}${count === 1 ? "" : "s"}`
}

function meta(source: Pick<PlanDoc, "width_m" | "height_m" | "access_points" | "walls">): string {
  return `${formatSize(source.width_m)} x ${formatSize(source.height_m)} m, ${plural(source.access_points.length, "router")}, ${plural(source.walls.length, "wall")}`
}

function RenameInput({
  initial,
  onDone,
  onSubmit,
}: {
  initial: string
  onDone: () => void
  onSubmit: (name: string) => Promise<void>
}) {
  const [value, setValue] = React.useState(initial)
  const [busy, setBusy] = React.useState(false)

  const submit = async () => {
    const name = value.trim()
    if (!name || name === initial) {
      onDone()
      return
    }
    setBusy(true)
    try {
      await onSubmit(name)
      onDone()
    } catch (err) {
      toast.error(errorMessage(err))
      setBusy(false)
    }
  }

  return (
    <Input
      autoFocus
      aria-label="Plan name"
      value={value}
      maxLength={NAME_MAX}
      disabled={busy}
      onChange={(event) => setValue(event.target.value)}
      onBlur={() => void submit()}
      onKeyDown={(event) => {
        if (event.key === "Enter") void submit()
        if (event.key === "Escape") onDone()
      }}
      className="h-7"
    />
  )
}

export function PlanList({
  plans,
  total,
  activeUuid,
  activeDoc,
  loading,
  error,
  loadingMore,
  onSelect,
  onCreate,
  onRename,
  onDelete,
  onLoadMore,
  onRetry,
}: PlanListProps & { activeDoc?: PlanDoc | null }) {
  const [renaming, setRenaming] = React.useState<string | null>(null)
  const [deleting, setDeleting] = React.useState<FloorPlanSummary | null>(null)
  const [busy, setBusy] = React.useState(false)

  const confirmDelete = async () => {
    if (!deleting) return
    setBusy(true)
    try {
      await onDelete(deleting)
      setDeleting(null)
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(false)
    }
  }

  let body: React.ReactNode
  if (loading) {
    body = <LoadingState label="Loading plans" className="min-h-32" />
  } else if (error && plans.length === 0) {
    body = (
      <EmptyState icon={<CircleAlertIcon />} title="Cannot load plans" className="min-h-32">
        <span className="font-data text-xs">{error}</span>
        <Button variant="outline" size="sm" onClick={onRetry}>
          Try again
        </Button>
      </EmptyState>
    )
  } else if (plans.length === 0) {
    body = <p className="px-4 py-4 text-[12px] text-text-3">No plans yet.</p>
  } else {
    body = (
      <ul className="flex flex-col py-1">
        {plans.map((plan) => {
          const active = plan.uuid === activeUuid
          const source = active && activeDoc ? activeDoc : plan
          return (
            <li
              key={plan.uuid}
              className={cn(
                "group flex items-center gap-1 px-2 py-0.5",
                active ? "bg-surface-3" : "hover:bg-surface-2",
              )}
            >
              {renaming === plan.uuid ? (
                <div className="min-w-0 flex-1 py-1 pl-1">
                  <RenameInput
                    initial={source.name}
                    onDone={() => setRenaming(null)}
                    onSubmit={(name) => onRename(plan.uuid, name)}
                  />
                </div>
              ) : (
                <button
                  type="button"
                  aria-current={active ? "true" : undefined}
                  onClick={() => onSelect(plan.uuid)}
                  className="flex min-w-0 flex-1 flex-col items-start gap-0.5 rounded-md px-2 py-1.5 text-left"
                >
                  <span className={cn("w-full truncate text-[13px]", active ? "text-foreground" : "text-text-2")}>
                    {source.name}
                  </span>
                  <span className="w-full truncate font-data text-[11px] text-text-3">{meta(source)}</span>
                </button>
              )}
              {renaming === plan.uuid ? null : (
                <div
                  className={cn(
                    "flex shrink-0 items-center opacity-0 transition-opacity group-focus-within:opacity-100 group-hover:opacity-100",
                    active && "opacity-100",
                  )}
                >
                  <IconButton label="Rename" size="icon-xs" side="bottom" onClick={() => setRenaming(plan.uuid)}>
                    <PencilIcon />
                  </IconButton>
                  <IconButton label="Delete" size="icon-xs" side="bottom" onClick={() => setDeleting(plan)}>
                    <Trash2Icon />
                  </IconButton>
                </div>
              )}
            </li>
          )
        })}
        {plans.length < total ? (
          <li className="px-4 py-2">
            <Button variant="ghost" size="xs" disabled={loadingMore} onClick={onLoadMore}>
              {loadingMore ? <Spinner className="size-3" /> : null}
              Load more
            </Button>
          </li>
        ) : null}
      </ul>
    )
  }

  return (
    <div className="flex flex-col">
      <div className="flex h-10 shrink-0 items-center justify-between border-b border-hairline pr-2 pl-4">
        <span className="text-xs text-text-3">
          Plans
          {total > 0 ? <span className="ml-1.5 font-data text-[11px]">{total}</span> : null}
        </span>
        <Button variant="outline" size="xs" onClick={onCreate}>
          <PlusIcon />
          New plan
        </Button>
      </div>
      {body}
      <AlertDialog open={deleting !== null} onOpenChange={(open) => !busy && !open && setDeleting(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete plan</AlertDialogTitle>
            <AlertDialogDescription>
              {deleting ? `${deleting.name} and its walls, routers and devices go away.` : null}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel asChild>
              <Button variant="outline" disabled={busy}>
                Cancel
              </Button>
            </AlertDialogCancel>
            <Button variant="destructive" onClick={confirmDelete} disabled={busy}>
              {busy ? <Spinner className="size-3.5 text-white" /> : null}
              Delete
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
