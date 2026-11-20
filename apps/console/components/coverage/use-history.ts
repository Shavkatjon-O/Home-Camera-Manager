"use client"

import * as React from "react"

import type { PlanDoc } from "@/lib/plan-edit"

const HISTORY_LIMIT = 100
const MERGE_WINDOW_MS = 1000

type Update = (doc: PlanDoc) => PlanDoc

interface HistoryState {
  past: PlanDoc[]
  present: PlanDoc
  future: PlanDoc[]
  origin: PlanDoc | null
  mergeKey: string | null
  mergeAt: number
}

type HistoryAction =
  | { type: "commit"; update: Update; merge: string | null; at: number }
  | { type: "begin" }
  | { type: "preview"; update: Update }
  | { type: "end" }
  | { type: "cancel" }
  | { type: "undo" }
  | { type: "redo" }

function settle(state: HistoryState, past: PlanDoc[], present: PlanDoc, future: PlanDoc[]): HistoryState {
  return { ...state, past: past.slice(-HISTORY_LIMIT), present, future, origin: null, mergeKey: null, mergeAt: 0 }
}

function reducer(state: HistoryState, action: HistoryAction): HistoryState {
  switch (action.type) {
    case "commit": {
      const next = action.update(state.present)
      if (next === state.present) return state
      if (state.origin) return { ...state, present: next }
      const merging =
        action.merge !== null && action.merge === state.mergeKey && action.at - state.mergeAt < MERGE_WINDOW_MS
      return {
        past: merging ? state.past : [...state.past, state.present].slice(-HISTORY_LIMIT),
        present: next,
        future: [],
        origin: null,
        mergeKey: action.merge,
        mergeAt: action.at,
      }
    }
    case "begin":
      return state.origin ? state : { ...state, origin: state.present }
    case "preview": {
      const next = action.update(state.present)
      return next === state.present ? state : { ...state, present: next }
    }
    case "end":
      if (!state.origin) return state
      if (state.origin === state.present) return { ...state, origin: null }
      return settle(state, [...state.past, state.origin], state.present, [])
    case "cancel":
      return state.origin ? { ...state, present: state.origin, origin: null } : state
    case "undo": {
      if (state.origin || state.past.length === 0) return state
      const previous = state.past[state.past.length - 1]
      return settle(state, state.past.slice(0, -1), previous, [state.present, ...state.future])
    }
    case "redo": {
      if (state.origin || state.future.length === 0) return state
      const [next, ...rest] = state.future
      return settle(state, [...state.past, state.present], next, rest)
    }
  }
}

export interface PlanHistory {
  doc: PlanDoc
  canUndo: boolean
  canRedo: boolean
  commit: (update: Update, merge?: string) => void
  begin: () => void
  preview: (update: Update) => void
  end: () => void
  cancel: () => void
  undo: () => void
  redo: () => void
}

export function usePlanHistory(initial: PlanDoc): PlanHistory {
  const [state, dispatch] = React.useReducer(reducer, initial, (doc) => ({
    past: [],
    present: doc,
    future: [],
    origin: null,
    mergeKey: null,
    mergeAt: 0,
  }))

  const actions = React.useMemo(
    () => ({
      commit: (update: Update, merge?: string) =>
        dispatch({ type: "commit", update, merge: merge ?? null, at: Date.now() }),
      begin: () => dispatch({ type: "begin" }),
      preview: (update: Update) => dispatch({ type: "preview", update }),
      end: () => dispatch({ type: "end" }),
      cancel: () => dispatch({ type: "cancel" }),
      undo: () => dispatch({ type: "undo" }),
      redo: () => dispatch({ type: "redo" }),
    }),
    [],
  )

  return {
    doc: state.present,
    canUndo: state.past.length > 0 && state.origin === null,
    canRedo: state.future.length > 0 && state.origin === null,
    ...actions,
  }
}
