"use client"

import * as React from "react"

import { Button } from "@/components/ui/button"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"

/** A square icon button with its label as the accessible name and a tooltip. */
export function IconButton({
  label,
  side = "bottom",
  variant = "ghost",
  size = "icon",
  ...props
}: Omit<React.ComponentProps<typeof Button>, "aria-label"> & {
  label: string
  side?: "top" | "bottom" | "left" | "right"
}) {
  return (
    <Tooltip>
      <TooltipTrigger asChild>
        <Button aria-label={label} variant={variant} size={size} {...props} />
      </TooltipTrigger>
      <TooltipContent side={side}>{label}</TooltipContent>
    </Tooltip>
  )
}
