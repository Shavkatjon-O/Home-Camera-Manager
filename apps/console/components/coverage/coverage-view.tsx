"use client"

import * as React from "react"
import {
  CheckIcon,
  CircleAlertIcon,
  MousePointer2Icon,
  PenLineIcon,
  Redo2Icon,
  RouterIcon,
  SmartphoneIcon,
  SquareIcon,
  Undo2Icon,
  WandSparklesIcon,
  WifiIcon,
} from "lucide-react"
import { toast } from "sonner"

import { CreatePlanDialog, CreatePlanForm } from "@/components/coverage/create-plan"
import { Inspector, type Suggestion } from "@/components/coverage/inspector"
import { PlanEditor, type Ghost } from "@/components/coverage/plan-editor"
import { PlanList, type PlanListProps } from "@/components/coverage/plan-list"
import { useAutosave, type SaveState } from "@/components/coverage/use-autosave"
import { startPlacement, useCoverageGrid, type PlacementRun } from "@/components/coverage/use-coverage"
import { usePlanHistory } from "@/components/coverage/use-history"
import { PageFrame } from "@/components/shell/page-frame"
import { IconButton } from "@/components/shell/icon-button"
import { Chip, EmptyState, LoadingState, Spinner } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
import { useCan } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { api, errorMessage, isAbort } from "@/lib/api"
import {
  BAND_LABELS,
  DEFAULT_MATERIAL,
  cellSizeFor,
  formatPercent,
  obstaclesFor,
  signalFrom,
  type CoverageInput,
} from "@/lib/coverage"
import { docFromPlan, type Selection, type Tool } from "@/lib/plan-edit"
import type { Band, Device, FloorPlan, FloorPlanSummary, WallMaterial } from "@/lib/types"
import { cn } from "@/lib/utils"

const PAGE_SIZE = 50

const PLAN_PARAM = "plan"

const FINE_CELL_M = 0.1
const FINE_CELLS_MAX = 160000
const COARSE_CELL_M = 0.3
const COARSE_CELLS_MAX = 12000

const TOOLS: { value: Tool; label: string; icon: React.ComponentType<{ className?: string }> }[] = [
  { value: "select", label: "Select", icon: MousePointer2Icon },
  { value: "wall", label: "Wall", icon: PenLineIcon },
  { value: "room", label: "Room", icon: SquareIcon },
  { value: "router", label: "Router", icon: RouterIcon },
  { value: "device", label: "Device", icon: SmartphoneIcon },
]

const BAND_OPTIONS: { value: Band; label: string }[] = [
  { value: "2.4", label: BAND_LABELS["2.4"] },
  { value: "5", label: BAND_LABELS["5"] },
]

const BAND_OPTIONS_SHORT: { value: Band; label: string }[] = [
  { value: "2.4", label: "2.4" },
  { value: "5", label: "5" },
]

function summaryOf(plan: FloorPlan): FloorPlanSummary {
  const { background_image, ...rest } = plan
  return { ...rest, has_background: background_image !== null }
}

function planParam(): string | null {
  try {
    return new URLSearchParams(window.location.search).get(PLAN_PARAM)
  } catch {
    return null
  }
}

function rememberPlan(uuid: string | null) {
  try {
    const url = new URL(window.location.href)
    if (uuid) url.searchParams.set(PLAN_PARAM, uuid)
    else url.searchParams.delete(PLAN_PARAM)
    window.history.replaceState(window.history.state, "", url)
  } catch {}
}

function ignore(): void {}

function editableTarget(target: EventTarget | null): boolean {
  if (!(target instanceof Element)) return false
  return Boolean(
    target.closest("input, textarea, select, [contenteditable='true'], [role='dialog'], [role='alertdialog'], [role='listbox']"),
  )
}

function ToolPicker({ value, onChange, className }: { value: Tool; onChange: (tool: Tool) => void; className?: string }) {
  return (
    <div
      role="radiogroup"
      aria-label="Tool"
      className={cn("h-8 items-center gap-0.5 rounded-md border border-input p-0.5", className)}
    >
      {TOOLS.map((tool) => {
        const active = tool.value === value
        const Icon = tool.icon
        return (
          <Tooltip key={tool.value}>
            <TooltipTrigger asChild>
              <button
                type="button"
                role="radio"
                aria-checked={active}
                aria-label={tool.label}
                onClick={() => onChange(tool.value)}
                className={cn(
                  "flex h-full items-center gap-1.5 rounded-[4px] px-2 font-mono text-[11px] text-text-2 transition-colors hover:text-foreground",
                  active && "bg-surface-3 text-foreground",
                )}
              >
                <Icon className="size-3.5" />
                <span className="hidden 2xl:inline">{tool.label}</span>
              </button>
            </TooltipTrigger>
            <TooltipContent side="bottom">{tool.label}</TooltipContent>
          </Tooltip>
        )
      })}
    </div>
  )
}

function SaveChip({ state }: { state: SaveState }) {
  if (state === "failed") {
    return (
      <Chip className="text-danger" data-testid="save-state">
        <CircleAlertIcon className="size-3" />
        Save failed
      </Chip>
    )
  }
  if (state === "saving") {
    return (
      <Chip data-testid="save-state">
        <Spinner className="size-3" />
        Saving
      </Chip>
    )
  }
  return (
    <Chip data-testid="save-state">
      <CheckIcon className="size-3" />
      Saved
    </Chip>
  )
}

function Columns({
  list,
  content,
  inspector,
}: {
  list: React.ReactNode
  content: React.ReactNode
  inspector?: React.ReactNode
}) {
  return (
    <div className="flex min-h-0 min-w-0 flex-1 flex-col overflow-y-auto lg:flex-row lg:overflow-hidden">
      <aside className="max-h-56 shrink-0 overflow-y-auto border-b border-hairline lg:max-h-none lg:w-[280px] lg:border-r lg:border-b-0">
        {list}
      </aside>
      <main className="relative h-[62dvh] shrink-0 lg:h-auto lg:min-h-0 lg:min-w-0 lg:flex-1">{content}</main>
      {inspector ? (
        <aside className="shrink-0 border-t border-hairline lg:w-[300px] lg:overflow-y-auto lg:border-t-0 lg:border-l">
          {inspector}
        </aside>
      ) : null}
    </div>
  )
}

function PlanWorkspace({
  plan,
  listProps,
  onSaved,
}: {
  plan: FloorPlan
  listProps: PlanListProps
  onSaved: (plan: FloorPlan) => void
}) {
  const canManage = useCan("admin")
  const [initial] = React.useState(() => docFromPlan(plan))
  const history = usePlanHistory(initial)
  const doc = history.doc
  const [tool, setTool] = React.useState<Tool>("select")
  const [band, setBand] = React.useState<Band>("2.4")
  const [selection, setSelection] = React.useState<Selection>(null)
  const [material, setMaterial] = React.useState<WallMaterial>(DEFAULT_MATERIAL)
  const [dragging, setDragging] = React.useState(false)
  const [alongWalls, setAlongWalls] = React.useState(true)
  const [suggestion, setSuggestion] = React.useState<Suggestion | null>(null)
  const placementRun = React.useRef<PlacementRun | null>(null)

  const saveState = useAutosave({ uuid: plan.uuid, initial, doc, paused: dragging, onSaved })

  const exponent = doc.settings.path_loss_exponent
  const input = React.useMemo<CoverageInput>(
    () => ({
      width: doc.width_m,
      height: doc.height_m,
      walls: doc.walls,
      accessPoints: doc.access_points,
      band,
      exponent,
    }),
    [doc.width_m, doc.height_m, doc.walls, doc.access_points, band, exponent],
  )
  const cell = dragging
    ? cellSizeFor(doc.width_m, doc.height_m, COARSE_CELL_M, COARSE_CELLS_MAX)
    : cellSizeFor(doc.width_m, doc.height_m, FINE_CELL_M, FINE_CELLS_MAX)
  const coverage = useCoverageGrid(input, cell, doc.settings.target_dbm)

  const obstacles = React.useMemo(
    () => ({ "2.4": obstaclesFor(doc.walls, "2.4"), "5": obstaclesFor(doc.walls, "5") }),
    [doc.walls],
  )

  const deviceSignals = React.useMemo(() => {
    const signals: Record<string, number> = {}
    for (const device of doc.devices) {
      let best = Number.NEGATIVE_INFINITY
      for (const accessPoint of doc.access_points) {
        best = Math.max(best, signalFrom(accessPoint, device, device.band, exponent, obstacles[device.band]))
      }
      signals[device.id] = best
    }
    return signals
  }, [doc.devices, doc.access_points, exponent, obstacles])

  const signalsFor = (device: Device) =>
    doc.access_points.map((accessPoint) => ({
      id: accessPoint.id,
      name: accessPoint.name,
      rssi: signalFrom(accessPoint, device, device.band, exponent, obstacles[device.band]),
    }))

  const ghosts: Ghost[] = []
  if (suggestion?.status === "done" && suggestion.result) {
    for (const move of suggestion.result.moves) {
      const accessPoint = doc.access_points.find((entry) => entry.id === move.id)
      if (!accessPoint || Math.hypot(move.x - accessPoint.x, move.y - accessPoint.y) < 0.01) continue
      ghosts.push({ id: move.id, name: accessPoint.name, from: accessPoint, to: move })
    }
  }

  const deleteSelection = () => {
    if (!selection) return
    const { kind, id } = selection
    history.commit((value) => {
      if (kind === "wall") return { ...value, walls: value.walls.filter((item) => item.id !== id) }
      if (kind === "ap") return { ...value, access_points: value.access_points.filter((item) => item.id !== id) }
      return { ...value, devices: value.devices.filter((item) => item.id !== id) }
    })
    setSelection(null)
  }

  const onKeyDown = React.useEffectEvent((event: KeyboardEvent) => {
    if (editableTarget(event.target)) return
    if (!canManage) {
      if (event.key === "Escape") setSelection(null)
      return
    }
    const key = event.key.toLowerCase()
    const modifier = event.ctrlKey || event.metaKey
    if (modifier && key === "z") {
      event.preventDefault()
      if (event.shiftKey) history.redo()
      else history.undo()
      return
    }
    if (modifier && key === "y") {
      event.preventDefault()
      history.redo()
      return
    }
    if (modifier || event.altKey) return
    if (event.key === "Delete" || event.key === "Backspace") {
      if (!selection) return
      event.preventDefault()
      deleteSelection()
      return
    }
    if (event.key === "Escape") setSelection(null)
  })

  React.useEffect(() => {
    const listener = (event: KeyboardEvent) => onKeyDown(event)
    window.addEventListener("keydown", listener)
    return () => window.removeEventListener("keydown", listener)
  }, [])

  const cancelRun = React.useEffectEvent(() => placementRun.current?.cancel())

  React.useEffect(() => () => cancelRun(), [])

  const suggest = () => {
    placementRun.current?.cancel()
    const runBand = band
    setSuggestion({ status: "running", progress: 0, band: runBand, result: null, ms: 0 })
    const run = startPlacement({ ...input, target: doc.settings.target_dbm, alongWalls }, (progress) =>
      setSuggestion((current) => (current?.status === "running" ? { ...current, progress } : current)),
    )
    placementRun.current = run
    run.done
      .then(({ result, ms }) => {
        if (placementRun.current !== run) return
        placementRun.current = null
        setSuggestion({ status: "done", progress: 1, band: runBand, result, ms })
      })
      .catch((err: unknown) => {
        if (placementRun.current !== run) return
        placementRun.current = null
        if (!(err instanceof Error && err.message === "cancelled")) toast.error(errorMessage(err))
        setSuggestion(null)
      })
  }

  const apply = () => {
    const moves = suggestion?.result?.moves ?? []
    history.commit((value) => ({
      ...value,
      access_points: value.access_points.map((accessPoint) => {
        const move = moves.find((entry) => entry.id === accessPoint.id)
        return move && (move.x !== accessPoint.x || move.y !== accessPoint.y)
          ? { ...accessPoint, x: move.x, y: move.y }
          : accessPoint
      }),
    }))
    setSuggestion(null)
    toast.success("Moved the routers to the suggested spots")
  }

  const discard = () => {
    placementRun.current?.cancel()
    placementRun.current = null
    setSuggestion(null)
  }

  const renameActive = async (uuid: string, name: string) => {
    if (uuid === plan.uuid) {
      history.commit((value) => ({ ...value, name }))
      return
    }
    await listProps.onRename(uuid, name)
  }

  const running = suggestion?.status === "running"
  const actions = (
    <>
      {canManage ? <ToolPicker value={tool} onChange={setTool} className="hidden md:flex" /> : null}
      <Segmented<Band> label="Band" value={band} options={BAND_OPTIONS} onChange={setBand} className="hidden sm:flex" />
      <Segmented<Band>
        label="Band in GHz"
        value={band}
        options={BAND_OPTIONS_SHORT}
        onChange={setBand}
        className="sm:hidden"
      />
      {canManage ? (
        <Button
          onClick={suggest}
          disabled={running || doc.access_points.length === 0}
          aria-label="Suggest placement"
          data-testid="suggest"
        >
          {running ? <Spinner className="size-3.5 text-primary-foreground" /> : <WandSparklesIcon />}
          <span className="hidden xl:inline">
            {running ? `Suggesting ${formatPercent(suggestion?.progress ?? 0)}` : "Suggest placement"}
          </span>
        </Button>
      ) : null}
    </>
  )

  return (
    <PageFrame actions={actions} status={canManage ? <SaveChip state={saveState} /> : null}>
      <Columns
        list={<PlanList {...listProps} activeDoc={doc} onRename={renameActive} />}
        content={
          <>
            <PlanEditor
              doc={doc}
              tool={tool}
              band={band}
              grid={coverage?.grid ?? null}
              selection={selection}
              material={material}
              ghosts={ghosts}
              deviceSignals={deviceSignals}
              onSelect={setSelection}
              onCommit={canManage ? history.commit : ignore}
              onGestureStart={canManage ? history.begin : ignore}
              onGesturePreview={canManage ? history.preview : ignore}
              onGestureEnd={canManage ? history.end : ignore}
              onDraggingChange={setDragging}
            />
            {canManage ? (
              <div
                className="absolute bottom-3 right-3 flex items-center gap-0.5 rounded-md border border-hairline bg-surface/90 p-0.5"
                onPointerDown={(event) => event.stopPropagation()}
              >
                <IconButton label="Undo" size="icon-sm" side="top" disabled={!history.canUndo} onClick={history.undo}>
                  <Undo2Icon />
                </IconButton>
                <IconButton label="Redo" size="icon-sm" side="top" disabled={!history.canRedo} onClick={history.redo}>
                  <Redo2Icon />
                </IconButton>
              </div>
            ) : null}
          </>
        }
        inspector={
          <Inspector
            doc={doc}
            band={band}
            selection={selection}
            stats={coverage?.stats ?? null}
            material={material}
            deviceSignals={signalsFor}
            alongWalls={alongWalls}
            suggestion={suggestion}
            onCommit={history.commit}
            onMaterialChange={setMaterial}
            onDelete={deleteSelection}
            onAlongWallsChange={setAlongWalls}
            onApply={apply}
            onDiscard={discard}
            readOnly={!canManage}
          />
        }
      />
    </PageFrame>
  )
}

/** The Coverage page: floor plans of the site with router placement and the Wi-Fi signal they give. */
export function CoverageView() {
  const canManage = useCan("admin")
  const [plans, setPlans] = React.useState<FloorPlanSummary[]>([])
  const [total, setTotal] = React.useState(0)
  const [listLoaded, setListLoaded] = React.useState(false)
  const [listError, setListError] = React.useState<string | null>(null)
  const [loadingMore, setLoadingMore] = React.useState(false)
  const [reload, setReload] = React.useState(0)
  const [activeUuid, setActiveUuid] = React.useState<string | null>(null)
  const [plan, setPlan] = React.useState<FloorPlan | null>(null)
  const [planError, setPlanError] = React.useState<{ uuid: string; message: string } | null>(null)
  const [createOpen, setCreateOpen] = React.useState(false)

  const select = React.useCallback((uuid: string | null) => {
    setActiveUuid(uuid)
    rememberPlan(uuid)
  }, [])

  const pickInitial = React.useEffectEvent((items: FloorPlanSummary[], count: number) => {
    if (activeUuid) return
    const wanted = planParam()
    const known = wanted !== null && (items.some((item) => item.uuid === wanted) || count > items.length)
    select(known ? wanted : (items[0]?.uuid ?? null))
  })

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .listFloorPlans({ page: 1, page_size: PAGE_SIZE }, controller.signal)
      .then((page) => {
        setPlans(page.items)
        setTotal(page.total)
        setListError(null)
        setListLoaded(true)
        pickInitial(page.items, page.total)
      })
      .catch((err: unknown) => {
        if (isAbort(err)) return
        setListError(errorMessage(err))
        setListLoaded(true)
      })
    return () => controller.abort()
  }, [reload])

  React.useEffect(() => {
    if (!activeUuid) return
    const controller = new AbortController()
    api
      .getFloorPlan(activeUuid, controller.signal)
      .then((loaded) => {
        setPlan(loaded)
        setPlanError(null)
      })
      .catch((err: unknown) => {
        if (isAbort(err)) return
        setPlanError({ uuid: activeUuid, message: errorMessage(err) })
      })
    return () => controller.abort()
  }, [activeUuid])

  const loadMore = () => {
    setLoadingMore(true)
    api
      .listFloorPlans({ page: Math.floor(plans.length / PAGE_SIZE) + 1, page_size: PAGE_SIZE })
      .then((page) => {
        setPlans((current) => {
          const known = new Set(current.map((item) => item.uuid))
          return [...current, ...page.items.filter((item) => !known.has(item.uuid))]
        })
        setTotal(page.total)
      })
      .catch((err: unknown) => toast.error(errorMessage(err)))
      .finally(() => setLoadingMore(false))
  }

  const created = (createdPlan: FloorPlan) => {
    setPlans((current) => [summaryOf(createdPlan), ...current])
    setTotal((current) => current + 1)
    setPlan(createdPlan)
    select(createdPlan.uuid)
  }

  const saved = React.useCallback((savedPlan: FloorPlan) => {
    setPlans((current) => current.map((item) => (item.uuid === savedPlan.uuid ? summaryOf(savedPlan) : item)))
  }, [])

  const rename = async (uuid: string, name: string) => {
    const renamed = await api.updateFloorPlan(uuid, { name })
    saved(renamed)
  }

  const remove = async (target: FloorPlanSummary) => {
    await api.deleteFloorPlan(target.uuid)
    toast.success(`Deleted ${target.name}`)
    const remaining = plans.filter((item) => item.uuid !== target.uuid)
    setPlans(remaining)
    setTotal((current) => Math.max(0, current - 1))
    if (target.uuid === activeUuid) select(remaining[0]?.uuid ?? null)
  }

  const listProps: PlanListProps = {
    plans,
    total,
    activeUuid,
    loading: !listLoaded,
    error: listError,
    loadingMore,
    onSelect: select,
    onCreate: () => setCreateOpen(true),
    onRename: rename,
    onDelete: remove,
    onLoadMore: loadMore,
    onRetry: () => setReload((value) => value + 1),
  }

  const loaded = plan && plan.uuid === activeUuid ? plan : null
  const failed = planError && planError.uuid === activeUuid ? planError.message : null

  let page: React.ReactNode
  if (loaded) {
    page = <PlanWorkspace key={loaded.uuid} plan={loaded} listProps={listProps} onSaved={saved} />
  } else {
    let content: React.ReactNode
    if (failed) {
      content = (
        <EmptyState icon={<CircleAlertIcon />} title="Cannot open this plan">
          <span className="font-data text-xs">{failed}</span>
          {plans.length > 0 ? (
            <Button variant="outline" onClick={() => select(plans[0].uuid)}>
              Open the newest plan
            </Button>
          ) : null}
        </EmptyState>
      )
    } else if (!listLoaded || activeUuid) {
      content = <LoadingState label="Loading plan" />
    } else if (listError) {
      content = (
        <EmptyState icon={<CircleAlertIcon />} title="Cannot load plans">
          <span className="font-data text-xs">{listError}</span>
        </EmptyState>
      )
    } else {
      content = (
        <EmptyState icon={<WifiIcon />} title="No floor plans yet">
          {canManage ? (
            <>
              <span>Create a plan, place your routers and see where the signal reaches. Walls are optional.</span>
              <CreatePlanForm onCreated={created} className="pt-2" />
            </>
          ) : (
            <span>An admin draws the floor plans of this site, with its routers and where their signal reaches.</span>
          )}
        </EmptyState>
      )
    }
    page = (
      <PageFrame>
        <Columns list={<PlanList {...listProps} />} content={content} />
      </PageFrame>
    )
  }

  return (
    <>
      {page}
      <CreatePlanDialog open={createOpen} onOpenChange={setCreateOpen} onCreated={created} />
    </>
  )
}
