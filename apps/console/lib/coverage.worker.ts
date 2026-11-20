import { computeGrid, gridStats, placementSteps, type CoverageInput, type PlacementInput } from "@/lib/coverage"

type CoverageRequest =
  | { type: "grid"; seq: number; input: CoverageInput; cell: number; target: number }
  | { type: "place"; seq: number; input: PlacementInput }

interface WorkerScope {
  onmessage: ((event: MessageEvent<CoverageRequest>) => void) | null
  postMessage: (message: unknown, transfer?: Transferable[]) => void
}

const scope = self as unknown as WorkerScope

scope.onmessage = (event) => {
  const request = event.data
  if (request.type === "grid") {
    const grid = computeGrid(request.input, request.cell)
    const stats = gridStats(grid, request.input.accessPoints.length, request.target)
    scope.postMessage({ type: "grid", seq: request.seq, grid, stats }, [grid.rssi.buffer, grid.best.buffer])
    return
  }
  const started = performance.now()
  const steps = placementSteps(request.input)
  let reported = 0
  let step = steps.next()
  while (!step.done) {
    if (step.value - reported >= 0.01) {
      reported = step.value
      scope.postMessage({ type: "progress", seq: request.seq, value: step.value })
    }
    step = steps.next()
  }
  scope.postMessage({ type: "placed", seq: request.seq, result: step.value, ms: performance.now() - started })
}
