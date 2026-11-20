"use client"

import * as React from "react"
import { CheckIcon, CircleAlertIcon, ExpandIcon, RefreshCwIcon, Trash2Icon, Undo2Icon } from "lucide-react"
import { toast } from "sonner"

import { RulePanel } from "@/components/analytics/rule-panel"
import { ZoneCanvas } from "@/components/analytics/zone-canvas"
import { IconButton } from "@/components/shell/icon-button"
import { EmptyState, LoadingState, Spinner } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
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
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import {
  WHOLE_VIEW,
  draftLine,
  draftZone,
  lineInput,
  newLine,
  newZone,
  nextName,
  rulesProblem,
  viewTitle,
  zoneInput,
  type DraftLine,
  type DraftZone,
  type RuleSelection,
  type Tool,
} from "@/lib/analytics"
import { ApiError, api, errorMessage, fetchViewSnapshot, isAbort } from "@/lib/api"
import type { AnalyticsView, ViewPoint } from "@/lib/types"

interface Picture {
  url: string
  reference: string | null
  aspect: number
}

const DEFAULT_ASPECT = 16 / 9

function plural(count: number, word: string): string {
  return `${count} ${word}${count === 1 ? "" : "s"}`
}

function readableError(error: unknown, zones: DraftZone[], lines: DraftLine[]): string {
  const message = errorMessage(error)
  if (!(error instanceof ApiError) || error.status !== 422) return message
  const match = /^(zones|lines)\.(\d+)(?:\.([\w.]+))?: (.*)$/.exec(message)
  if (!match) return message
  const items: { name: string }[] = match[1] === "zones" ? zones : lines
  const item = items[Number(match[2])]
  if (!item) return message
  return match[3] ? `${item.name}, ${match[3].replace(/_/g, " ")}: ${match[4]}` : `${item.name}: ${match[4]}`
}

export function ZoneEditor({
  view,
  onClose,
  onSaved,
}: {
  view: AnalyticsView
  onClose: () => void
  onSaved: (view: AnalyticsView) => void
}) {
  const [zones, setZones] = React.useState<DraftZone[]>(() => view.zones.map(draftZone))
  const [lines, setLines] = React.useState<DraftLine[]>(() => view.lines.map(draftLine))
  const [selection, setSelection] = React.useState<RuleSelection>(null)
  const [vertex, setVertex] = React.useState<number | null>(null)
  const [tool, setTool] = React.useState<Tool>("select")
  const [draft, setDraft] = React.useState<ViewPoint[]>([])
  const [picture, setPicture] = React.useState<Picture | null>(null)
  const [pictureError, setPictureError] = React.useState<string | null>(null)
  const [attempt, setAttempt] = React.useState(0)
  const [dirty, setDirty] = React.useState(false)
  const [saving, setSaving] = React.useState(false)
  const [confirmClose, setConfirmClose] = React.useState(false)
  const counter = React.useRef(0)

  React.useEffect(() => {
    const controller = new AbortController()
    let url: string | null = null
    fetchViewSnapshot(view.uuid, controller.signal)
      .then(async (result) => {
        url = result.url
        if (controller.signal.aborted) {
          URL.revokeObjectURL(result.url)
          return
        }
        const image = new window.Image()
        image.src = result.url
        await image.decode()
        if (controller.signal.aborted) return
        const aspect =
          image.naturalWidth > 0 && image.naturalHeight > 0 ? image.naturalWidth / image.naturalHeight : DEFAULT_ASPECT
        setPicture({ url: result.url, reference: result.reference, aspect })
      })
      .catch((err: unknown) => {
        if (controller.signal.aborted || isAbort(err)) return
        setPictureError(errorMessage(err))
      })
    return () => {
      controller.abort()
      if (url) URL.revokeObjectURL(url)
    }
  }, [view.uuid, attempt])

  const newKey = () => {
    counter.current += 1
    return `new-${counter.current}`
  }

  const changeZones = (update: (current: DraftZone[]) => DraftZone[]) => {
    setZones(update)
    setDirty(true)
  }

  const changeLines = (update: (current: DraftLine[]) => DraftLine[]) => {
    setLines(update)
    setDirty(true)
  }

  const updateZone = (key: string, changes: Partial<DraftZone>) =>
    changeZones((current) => current.map((zone) => (zone.key === key ? { ...zone, ...changes } : zone)))

  const updateLine = (key: string, changes: Partial<DraftLine>) =>
    changeLines((current) => current.map((line) => (line.key === key ? { ...line, ...changes } : line)))

  const select = (next: RuleSelection, point: number | null = null) => {
    setSelection(next)
    setVertex(point)
  }

  const changeTool = (next: Tool) => {
    setTool(next)
    setDraft([])
    if (next !== "select") select(null)
  }

  const finishZone = (points: ViewPoint[]) => {
    if (points.length < 3) return
    const key = newKey()
    const name = nextName("Zone", zones.map((zone) => zone.name))
    changeZones((current) => [...current, newZone(key, name, points, false)])
    setDraft([])
    setTool("select")
    select({ kind: "zone", key })
  }

  const finishLine = (points: [ViewPoint, ViewPoint]) => {
    const key = newKey()
    const name = nextName("Line", lines.map((line) => line.name))
    changeLines((current) => [...current, newLine(key, name, points)])
    setDraft([])
    setTool("select")
    select({ kind: "line", key })
  }

  const addWholeView = () => {
    const key = newKey()
    const name = nextName("Zone", zones.map((zone) => zone.name))
    const polygon = WHOLE_VIEW.map((point): ViewPoint => [point[0], point[1]])
    changeZones((current) => [...current, newZone(key, name, polygon, true)])
    setDraft([])
    setTool("select")
    select({ kind: "zone", key })
  }

  const selectedZone = selection?.kind === "zone" ? zones.find((zone) => zone.key === selection.key) : undefined
  const canDeletePoint =
    tool === "select" && selectedZone !== undefined && !selectedZone.whole_view && vertex !== null && selectedZone.polygon.length > 3

  const deletePoint = () => {
    if (!canDeletePoint || !selectedZone || vertex === null) return
    updateZone(selectedZone.key, { polygon: selectedZone.polygon.filter((_, index) => index !== vertex) })
    setVertex(null)
  }

  const remove = (item: NonNullable<RuleSelection>) => {
    if (item.kind === "zone") changeZones((current) => current.filter((zone) => zone.key !== item.key))
    else changeLines((current) => current.filter((line) => line.key !== item.key))
    select(null)
  }

  const retake = () => {
    setPicture(null)
    setPictureError(null)
    setDraft([])
    setAttempt((value) => value + 1)
  }

  const requestClose = () => {
    if (saving) return
    if (dirty) setConfirmClose(true)
    else onClose()
  }

  const save = async () => {
    if (!picture || saving) return
    const problem = rulesProblem(zones, lines)
    if (problem) {
      toast.error(problem)
      return
    }
    setSaving(true)
    try {
      const saved = await api.saveAnalyticsRules(view.uuid, {
        zones: zones.map((zone) => zoneInput(zone, picture.reference)),
        lines: lines.map((line) => lineInput(line, picture.reference)),
      })
      toast.success(`Saved ${plural(saved.zones.length, "zone")} and ${plural(saved.lines.length, "line")}`)
      setDirty(false)
      onSaved(saved)
      onClose()
    } catch (err) {
      toast.error(readableError(err, zones, lines))
      setSaving(false)
    }
  }

  const onKey = React.useEffectEvent((event: KeyboardEvent) => {
    const target = event.target as HTMLElement | null
    if (target?.closest("input, textarea, [role='listbox'], [role='combobox'], [role='alertdialog']")) return
    if (event.key === "Enter" && tool === "zone" && draft.length >= 3) {
      event.preventDefault()
      finishZone(draft)
      return
    }
    if ((event.key === "Delete" || event.key === "Backspace") && canDeletePoint) {
      event.preventDefault()
      deletePoint()
    }
  })

  React.useEffect(() => {
    const listener = (event: KeyboardEvent) => onKey(event)
    window.addEventListener("keydown", listener)
    return () => window.removeEventListener("keydown", listener)
  }, [])

  const title = view.lenses > 1 && view.lens > 0 ? `${view.camera_name}, ${viewTitle(view)}` : view.camera_name

  let canvas: React.ReactNode
  if (picture) {
    canvas = (
      <ZoneCanvas
        imageUrl={picture.url}
        aspect={picture.aspect}
        zones={zones}
        lines={lines}
        selection={selection}
        vertex={vertex}
        tool={tool}
        draft={draft}
        onSelect={select}
        onDraft={setDraft}
        onFinishZone={finishZone}
        onFinishLine={finishLine}
        onZoneShape={(key, polygon) => updateZone(key, { polygon })}
        onLineShape={(key, points) => updateLine(key, { points })}
      />
    )
  } else if (pictureError) {
    canvas = (
      <div className="min-h-0 flex-1">
        <EmptyState icon={<CircleAlertIcon />} title="No picture of this view">
          <span className="font-data text-xs">{pictureError}</span>
          <Button variant="outline" onClick={retake}>
            Try again
          </Button>
        </EmptyState>
      </div>
    )
  } else {
    canvas = <LoadingState label="Taking a picture" className="min-h-0 flex-1" />
  }

  return (
    <>
      <Dialog
        open
        onOpenChange={(open) => {
          if (!open) requestClose()
        }}
      >
        <DialogContent
          className="top-0 left-0 h-dvh max-h-none w-full max-w-none translate-x-0 translate-y-0 rounded-none border-0"
          onEscapeKeyDown={(event) => {
            if (draft.length > 0 || tool !== "select") {
              event.preventDefault()
              changeTool("select")
            }
          }}
        >
          <DialogHeader>
            <DialogTitle className="truncate">Zones and lines of {title}</DialogTitle>
            <DialogDescription className="hidden sm:block">
              Drawn on a fresh picture of the view. Saving ties every zone and line to this picture.
            </DialogDescription>
          </DialogHeader>
          <div className="flex min-h-0 flex-1 flex-col lg:flex-row">
            <div className="flex h-[48dvh] shrink-0 flex-col lg:h-auto lg:min-h-0 lg:min-w-0 lg:flex-1">
              <div className="flex shrink-0 flex-wrap items-center gap-2 border-b border-hairline px-3 py-2">
                <Segmented<Tool>
                  label="Tool"
                  value={tool}
                  options={[
                    { value: "select", label: "Select" },
                    { value: "zone", label: "Draw zone", disabled: !picture },
                    { value: "line", label: "Draw line", disabled: !picture },
                  ]}
                  onChange={changeTool}
                />
                <Button variant="outline" size="sm" disabled={!picture} onClick={addWholeView}>
                  <ExpandIcon />
                  Whole view
                </Button>
                {tool === "zone" && draft.length > 0 ? (
                  <>
                    <Button size="sm" disabled={draft.length < 3} onClick={() => finishZone(draft)}>
                      <CheckIcon />
                      Finish
                    </Button>
                    <Button variant="ghost" size="sm" onClick={() => setDraft((current) => current.slice(0, -1))}>
                      <Undo2Icon />
                      Undo point
                    </Button>
                  </>
                ) : null}
                {canDeletePoint ? (
                  <Button variant="ghost" size="sm" onClick={deletePoint}>
                    <Trash2Icon />
                    Delete point
                  </Button>
                ) : null}
                <div className="min-w-0 flex-1" />
                <IconButton
                  label="Take a new picture"
                  size="icon-sm"
                  disabled={!picture && !pictureError}
                  onClick={retake}
                >
                  <RefreshCwIcon />
                </IconButton>
              </div>
              {canvas}
            </div>
            <aside
              aria-label="Zones and lines"
              className="min-h-0 flex-1 overflow-y-auto border-t border-hairline lg:w-[360px] lg:flex-none lg:border-t-0 lg:border-l"
            >
              <RulePanel
                zones={zones}
                lines={lines}
                selection={selection}
                onSelect={(next) => select(next)}
                onZone={updateZone}
                onLine={updateLine}
                onRemove={remove}
              />
            </aside>
          </div>
          <DialogFooter className="justify-between">
            <span className="min-w-0 truncate font-data text-[11px] text-text-3">
              {plural(zones.length, "zone")}, {plural(lines.length, "line")}
            </span>
            <div className="flex shrink-0 items-center gap-2">
              <Button variant="ghost" disabled={saving} onClick={requestClose}>
                Cancel
              </Button>
              <Button disabled={saving || !picture} onClick={() => void save()}>
                {saving ? <Spinner className="size-3.5" /> : null}
                Save
              </Button>
            </div>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      <AlertDialog open={confirmClose} onOpenChange={setConfirmClose}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Discard your changes?</AlertDialogTitle>
            <AlertDialogDescription>The zones and lines stay as they were last saved.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel asChild>
              <Button variant="outline">Keep editing</Button>
            </AlertDialogCancel>
            <Button
              onClick={() => {
                setConfirmClose(false)
                onClose()
              }}
            >
              Discard
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}
