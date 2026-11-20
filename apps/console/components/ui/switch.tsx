"use client"

import * as React from "react"
import { Switch as SwitchPrimitive } from "radix-ui"

import { cn } from "@/lib/utils"

function Switch({ className, ...props }: React.ComponentProps<typeof SwitchPrimitive.Root>) {
  return (
    <SwitchPrimitive.Root
      data-slot="switch"
      className={cn(
        "peer inline-flex h-[18px] w-8 shrink-0 items-center rounded-full border border-transparent transition-colors outline-none disabled:cursor-not-allowed disabled:opacity-50 data-[state=checked]:bg-primary data-[state=unchecked]:bg-surface-3",
        className,
      )}
      {...props}
    >
      <SwitchPrimitive.Thumb
        data-slot="switch-thumb"
        className="pointer-events-none block size-3.5 rounded-full bg-background ring-0 transition-transform data-[state=checked]:translate-x-[15px] data-[state=unchecked]:translate-x-[1px] data-[state=unchecked]:bg-text-2"
      />
    </SwitchPrimitive.Root>
  )
}

export { Switch }
