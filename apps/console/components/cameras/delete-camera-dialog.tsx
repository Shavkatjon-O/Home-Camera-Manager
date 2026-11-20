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
import { api, errorMessage } from "@/lib/api"
import type { Camera } from "@/lib/types"

export function DeleteCameraDialog({
  camera,
  onOpenChange,
  onDeleted,
}: {
  camera: Camera | null
  onOpenChange: (open: boolean) => void
  onDeleted: (camera: Camera) => void
}) {
  const [busy, setBusy] = React.useState(false)

  const confirm = async () => {
    if (!camera) return
    setBusy(true)
    try {
      await api.deleteCamera(camera.uuid)
      toast.success(`Deleted ${camera.name}`)
      onDeleted(camera)
      onOpenChange(false)
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(false)
    }
  }

  return (
    <AlertDialog open={camera !== null} onOpenChange={(open) => !busy && onOpenChange(open)}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete camera</AlertDialogTitle>
          <AlertDialogDescription>
            {camera ? `${camera.name} leaves the wall and its streams stop.` : null}
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
