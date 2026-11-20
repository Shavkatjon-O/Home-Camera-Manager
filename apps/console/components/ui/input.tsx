import * as React from "react"

import { cn } from "@/lib/utils"

function Input({ className, type, ...props }: React.ComponentProps<"input">) {
  return (
    <input
      type={type}
      data-slot="input"
      className={cn(
        "h-8 w-full min-w-0 rounded-md border border-input bg-transparent px-2.5 text-[13px] text-foreground transition-colors outline-none placeholder:text-text-3 hover:border-hairline-strong focus-visible:border-hairline-strong disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-status-err",
        className,
      )}
      {...props}
    />
  )
}

export { Input }
