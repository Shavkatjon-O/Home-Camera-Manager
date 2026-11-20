"use client"

import * as React from "react"
import { CircleAlertIcon, CircleCheckIcon, CircleDashedIcon } from "lucide-react"

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
import { errorMessage } from "@/lib/api"
import { PHOTO_UNREADABLE, downscalePhoto, peopleApi, type Person } from "@/lib/people"
import { cn } from "@/lib/utils"

export type UploadState = "waiting" | "preparing" | "uploading" | "added" | "rejected" | "failed" | "skipped"

export interface UploadItem {
  id: string
  name: string
  state: UploadState
  reasons: string[]
}

export interface PhotoQueue {
  items: UploadItem[]
  running: boolean
  stopping: boolean
  start: (personUuid: string, files: File[], onPerson: (person: Person) => void) => Promise<void>
  stop: () => void
  reset: () => void
}

const STATE_LABELS: Record<UploadState, string> = {
  waiting: "Waiting",
  preparing: "Preparing",
  uploading: "Uploading",
  added: "Added",
  rejected: "Not added",
  failed: "Failed",
  skipped: "Not sent",
}

export const PHOTO_ACCEPT = "image/*"

export function usePhotoUpload(): PhotoQueue {
  const [items, setItems] = React.useState<UploadItem[]>([])
  const [running, setRunning] = React.useState(false)
  const [stopping, setStopping] = React.useState(false)
  const stopRef = React.useRef(false)
  const runningRef = React.useRef(false)

  const patch = React.useCallback((id: string, change: Partial<UploadItem>) => {
    setItems((current) => current.map((item) => (item.id === id ? { ...item, ...change } : item)))
  }, [])

  const start = React.useCallback(
    async (personUuid: string, files: File[], onPerson: (person: Person) => void) => {
      if (runningRef.current || files.length === 0) return
      const queued: UploadItem[] = files.map((file, index) => ({
        id: `${index}-${file.name}-${file.size}-${file.lastModified}`,
        name: file.name || `Photo ${index + 1}`,
        state: "waiting",
        reasons: [],
      }))
      runningRef.current = true
      stopRef.current = false
      setItems(queued)
      setRunning(true)
      setStopping(false)
      for (let index = 0; index < files.length; index += 1) {
        const item = queued[index]
        if (stopRef.current) {
          patch(item.id, { state: "skipped" })
          continue
        }
        patch(item.id, { state: "preparing" })
        let data: string
        try {
          data = await downscalePhoto(files[index])
        } catch (err) {
          patch(item.id, { state: "rejected", reasons: [err instanceof Error ? err.message : PHOTO_UNREADABLE] })
          continue
        }
        patch(item.id, { state: "uploading" })
        try {
          const result = await peopleApi.addPhotos(personUuid, [{ name: item.name, data }])
          onPerson(result.person)
          const reasons = result.rejected.map((rejection) => rejection.reason)
          if (result.added.length > 0) patch(item.id, { state: "added", reasons })
          else patch(item.id, { state: "rejected", reasons: reasons.length > 0 ? reasons : ["The photo was not added"] })
        } catch (err) {
          patch(item.id, { state: "failed", reasons: [errorMessage(err)] })
        }
      }
      runningRef.current = false
      setRunning(false)
      setStopping(false)
    },
    [patch],
  )

  const stop = React.useCallback(() => {
    if (!runningRef.current) return
    stopRef.current = true
    setStopping(true)
  }, [])

  const reset = React.useCallback(() => {
    if (runningRef.current) return
    setItems([])
  }, [])

  return { items, running, stopping, start, stop, reset }
}

function StateIcon({ state }: { state: UploadState }) {
  if (state === "preparing" || state === "uploading") return <Spinner className="mt-0.5 size-3.5" />
  if (state === "added") return <CircleCheckIcon aria-hidden className="mt-0.5 size-3.5 shrink-0 text-status-ok" />
  if (state === "rejected" || state === "failed") {
    return <CircleAlertIcon aria-hidden className="mt-0.5 size-3.5 shrink-0 text-danger" />
  }
  return <CircleDashedIcon aria-hidden className="mt-0.5 size-3.5 shrink-0 text-text-3" />
}

export function uploadSummary(items: UploadItem[], running: boolean): string {
  const finished = items.filter((item) => !["waiting", "preparing", "uploading"].includes(item.state)).length
  if (running) return `${finished} of ${items.length} done`
  const added = items.filter((item) => item.state === "added").length
  const missed = items.length - added
  if (missed === 0) return added === 1 ? "The photo was added" : `All ${added} photos were added`
  return `${added} added, ${missed} not added`
}

export function UploadList({ items, className }: { items: UploadItem[]; className?: string }) {
  return (
    <ul aria-label="Photos" className={cn("flex flex-col", className)}>
      {items.map((item) => (
        <li key={item.id} className="flex items-start gap-3 border-b border-hairline py-2.5 last:border-b-0">
          <StateIcon state={item.state} />
          <div className="flex min-w-0 flex-1 flex-col gap-0.5">
            <span className="truncate text-[13px] text-foreground">{item.name}</span>
            <span
              className={cn(
                "text-[12px]",
                item.state === "added" ? "text-status-ok" : item.state === "rejected" || item.state === "failed" ? "text-danger" : "text-text-3",
              )}
            >
              {STATE_LABELS[item.state]}
            </span>
            {item.reasons.map((reason, index) => (
              <span key={index} className="text-[12px] text-text-2">
                {reason}
              </span>
            ))}
          </div>
        </li>
      ))}
    </ul>
  )
}

export function UploadProgress({ name, upload, onDone }: { name: string; upload: PhotoQueue; onDone: () => void }) {
  return (
    <>
      <DialogHeader>
        <DialogTitle>Adding photos of {name}</DialogTitle>
        <DialogDescription>
          Each photo needs exactly one face, close and clear. Photos go one at a time to this computer, which keeps
          only the face.
        </DialogDescription>
      </DialogHeader>
      <DialogBody className="flex flex-col gap-2">
        <span aria-live="polite" className="font-data text-[11px] text-text-3">
          {uploadSummary(upload.items, upload.running)}
        </span>
        <UploadList items={upload.items} />
      </DialogBody>
      <DialogFooter>
        {upload.running ? (
          <Button variant="outline" onClick={upload.stop} disabled={upload.stopping}>
            {upload.stopping ? <Spinner className="size-3.5" /> : null}
            {upload.stopping ? "Stopping" : "Stop"}
          </Button>
        ) : (
          <Button onClick={onDone}>Done</Button>
        )}
      </DialogFooter>
    </>
  )
}

export function PhotoUploadDialog({
  person,
  upload,
  onClose,
}: {
  person: Person | null
  upload: PhotoQueue
  onClose: () => void
}) {
  const close = () => {
    if (upload.running) return
    onClose()
  }
  return (
    <Dialog open={person !== null} onOpenChange={(open) => !open && close()}>
      <DialogContent>{person ? <UploadProgress name={person.name} upload={upload} onDone={close} /> : null}</DialogContent>
    </Dialog>
  )
}
