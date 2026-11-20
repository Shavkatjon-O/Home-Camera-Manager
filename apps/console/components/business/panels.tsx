"use client"

import { CircleAlertIcon } from "lucide-react"

import { EmptyState, LoadingState } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"

/**
 * Shows that a page is loading.
 *
 * @param props - The label to show.
 * @returns The loading state.
 */
export function PageLoading({ label }: { label: string }) {
  return <LoadingState label={label} />
}

/**
 * Shows a failure with an optional retry button.
 *
 * @param props - The title, the message and the retry handler.
 * @returns The error state.
 */
export function PageError({ title, message, onRetry }: { title: string; message: string; onRetry?: () => void }) {
  return (
    <EmptyState icon={<CircleAlertIcon />} title={title}>
      <span className="font-data text-xs">{message}</span>
      {onRetry ? (
        <Button variant="outline" onClick={onRetry}>
          Try again
        </Button>
      ) : null}
    </EmptyState>
  )
}

/**
 * Shows that the signed in user may not see a page.
 *
 * @param props - The title and the explanation.
 * @returns The restricted state.
 */
export function PageRestricted({ title, message }: { title: string; message: string }) {
  return (
    <EmptyState icon={<CircleAlertIcon />} title={title}>
      <span>{message}</span>
    </EmptyState>
  )
}
