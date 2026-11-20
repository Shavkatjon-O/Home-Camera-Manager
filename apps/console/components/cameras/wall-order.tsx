"use client"

import * as React from "react"
import { ArrowDownIcon, ArrowUpIcon } from "lucide-react"
import { toast } from "sonner"

import { IconButton } from "@/components/shell/icon-button"
import { Chip, EmptyState, LoadingState, StatusDot } from "@/components/shell/primitives"
import { useCan, useSession } from "@/components/shell/session"
import { api, errorMessage } from "@/lib/api"

/** The cameras in the order the wall shows them; admins move them up and down. */
export function WallOrder() {
  const { cameras, loaded, refresh } = useSession()
  const canManage = useCan("admin")
  const [saving, setSaving] = React.useState(false)

  const move = async (index: number, delta: number) => {
    const target = index + delta
    if (target < 0 || target >= cameras.length) return
    const order = cameras.map((camera) => camera.uuid)
    const [moved] = order.splice(index, 1)
    order.splice(target, 0, moved)
    setSaving(true)
    try {
      await api.reorderCameras(order)
      await refresh()
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="flex flex-col">
      <div className="flex h-10 shrink-0 items-center justify-between border-b border-hairline px-4">
        <span className="text-xs text-text-3">Wall order</span>
        {saving ? <span className="font-mono text-[11px] text-text-3">Saving</span> : null}
      </div>
      {!loaded ? (
        <LoadingState label="Loading" className="min-h-32" />
      ) : cameras.length === 0 ? (
        <EmptyState title="Nothing to order" className="min-h-32">
          Cameras appear here in the order the wall shows them.
        </EmptyState>
      ) : (
        <ol className="flex flex-col py-1">
          {cameras.map((camera, index) => (
            <li key={camera.uuid} className="flex items-center gap-2 px-4 py-1.5">
              <span className="w-5 shrink-0 font-data text-[11px] text-text-3">{index + 1}</span>
              <StatusDot online={camera.status.online} />
              <div className="flex min-w-0 flex-1 flex-col">
                <span className="truncate text-[13px] text-foreground">{camera.name}</span>
                {camera.location ? (
                  <span className="truncate text-[11px] text-text-3">{camera.location}</span>
                ) : null}
              </div>
              {!camera.enabled ? <Chip>Disabled</Chip> : null}
              {canManage ? (
                <>
                  <IconButton
                    label="Move up"
                    size="icon-xs"
                    side="left"
                    disabled={saving || index === 0}
                    onClick={() => void move(index, -1)}
                  >
                    <ArrowUpIcon />
                  </IconButton>
                  <IconButton
                    label="Move down"
                    size="icon-xs"
                    side="left"
                    disabled={saving || index === cameras.length - 1}
                    onClick={() => void move(index, 1)}
                  >
                    <ArrowDownIcon />
                  </IconButton>
                </>
              ) : null}
            </li>
          ))}
        </ol>
      )}
    </div>
  )
}
