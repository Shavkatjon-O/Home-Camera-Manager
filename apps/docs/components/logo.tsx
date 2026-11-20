import { CctvIcon } from "lucide-react"

import { productName } from "@/lib/site"

/**
 * The site's mark in the navigation bar: the console's camera icon, the product name and the word Docs.
 *
 * @returns The mark.
 */
export function Logo() {
  return (
    <span className="inline-flex items-center gap-2">
      <CctvIcon aria-hidden className="size-4 shrink-0 text-fd-muted-foreground" />
      <span className="text-[14px] font-medium tracking-tight">{productName}</span>
      <span className="rounded-md bg-fd-secondary px-1.5 py-0.5 font-mono text-[11px] text-fd-muted-foreground">
        Docs
      </span>
    </span>
  )
}
