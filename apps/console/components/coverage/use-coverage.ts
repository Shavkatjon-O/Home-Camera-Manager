"use client"

import * as React from "react"

import {
  computeGrid,
  gridStats,
  placementSteps,
  type CoverageGrid,
  type CoverageInput,
  type CoverageStats,
  type PlacementInput,
  type PlacementResult,
} from "@/lib/coverage"

export interface GridResult {
  grid: CoverageGrid
  stats: CoverageStats
}

interface GridJob {
  input: CoverageInput
  cell: number
  target: number
}

type WorkerReply =
  | { type: "grid"; seq: number; grid: CoverageGrid; stats: CoverageStats }
  | { type: "progress"; seq: number; value: number }
  | { type: "placed"; seq: number; result: PlacementResult; ms: number }

const INLINE_SLICE_MS = 12

function createWorker(): Worker | null {
  if (typeof Worker === "undefined") return null
  try {
    return new Worker(new URL("../../lib/coverage.worker.ts", import.meta.url), { type: "module" })
  } catch {
    return null
  }
}

class GridEngine {
  worker: Worker | null
  busy = false
  pending: GridJob | null = null
  seq = 0
  disposed = false

  constructor(private readonly onResult: (result: GridResult) => void) {
    this.worker = createWorker()
    if (!this.worker) return
    this.worker.onmessage = (event: MessageEvent<WorkerReply>) => {
      const reply = event.data
      if (reply.type === "grid" && reply.seq === this.seq) this.finish({ grid: reply.grid, stats: reply.stats })
    }
    this.worker.onerror = () => {
      this.worker?.terminate()
      this.worker = null
      this.busy = false
      const next = this.pending
      this.pending = null
      if (next) this.start(next)
    }
  }

  request(job: GridJob) {
    if (this.busy) {
      this.pending = job
      return
    }
    this.start(job)
  }

  start(job: GridJob) {
    this.busy = true
    this.seq += 1
    if (this.worker) {
      this.worker.postMessage({ type: "grid", seq: this.seq, input: job.input, cell: job.cell, target: job.target })
      return
    }
    window.setTimeout(() => {
      if (this.disposed) return
      const grid = computeGrid(job.input, job.cell)
      this.finish({ grid, stats: gridStats(grid, job.input.accessPoints.length, job.target) })
    }, 0)
  }

  finish(result: GridResult) {
    this.busy = false
    if (this.disposed) return
    this.onResult(result)
    const next = this.pending
    this.pending = null
    if (next) this.start(next)
  }

  dispose() {
    this.disposed = true
    this.worker?.terminate()
  }
}

export function useCoverageGrid(input: CoverageInput, cell: number, target: number): GridResult | null {
  const [result, setResult] = React.useState<GridResult | null>(null)
  const engine = React.useRef<GridEngine | null>(null)

  React.useEffect(() => {
    const created = new GridEngine(setResult)
    engine.current = created
    return () => {
      created.dispose()
      engine.current = null
    }
  }, [])

  React.useEffect(() => {
    engine.current?.request({ input, cell, target })
  }, [input, cell, target])

  return result
}

export interface PlacementRun {
  done: Promise<{ result: PlacementResult; ms: number }>
  cancel: () => void
}

export function startPlacement(input: PlacementInput, onProgress: (value: number) => void): PlacementRun {
  const worker = createWorker()
  if (worker) {
    let settled = false
    let rejectRun: (reason: Error) => void = () => undefined
    const done = new Promise<{ result: PlacementResult; ms: number }>((resolve, reject) => {
      rejectRun = reject
      worker.onmessage = (event: MessageEvent<WorkerReply>) => {
        const reply = event.data
        if (reply.type === "progress") onProgress(reply.value)
        if (reply.type === "placed") {
          settled = true
          worker.terminate()
          resolve({ result: reply.result, ms: reply.ms })
        }
      }
      worker.onerror = (event) => {
        settled = true
        worker.terminate()
        reject(new Error(event.message || "The placement worker failed"))
      }
    })
    worker.postMessage({ type: "place", seq: 1, input })
    return {
      done,
      cancel: () => {
        if (settled) return
        settled = true
        worker.terminate()
        rejectRun(new Error("cancelled"))
      },
    }
  }
  let cancelled = false
  const done = new Promise<{ result: PlacementResult; ms: number }>((resolve, reject) => {
    const started = performance.now()
    const steps = placementSteps(input)
    const slice = () => {
      if (cancelled) {
        reject(new Error("cancelled"))
        return
      }
      const until = performance.now() + INLINE_SLICE_MS
      let step = steps.next()
      while (!step.done && performance.now() < until) step = steps.next()
      if (step.done) {
        resolve({ result: step.value, ms: performance.now() - started })
        return
      }
      onProgress(step.value)
      window.setTimeout(slice, 0)
    }
    window.setTimeout(slice, 0)
  })
  return {
    done,
    cancel: () => {
      cancelled = true
    },
  }
}
