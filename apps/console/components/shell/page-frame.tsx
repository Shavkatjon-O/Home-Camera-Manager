"use client"

import * as React from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { ChevronRightIcon } from "lucide-react"

import { findItem, normalizePath } from "@/components/shell/navigation"
import { cn } from "@/lib/utils"

const CONTAINED = "mx-auto w-full max-w-6xl"

/** A page above the current one, linked from the page header. */
export interface PageParent {
  href: string
  label: string
}

/**
 * The header of a page's content area: the title with an optional parent link, status and description on the
 * left, the page's own actions on the right, and an optional toolbar row of filters below.
 */
export function PageHeader({
  title,
  description,
  parent,
  status,
  actions,
  toolbar,
  contained = false,
}: {
  title: string
  description?: React.ReactNode
  parent?: PageParent
  status?: React.ReactNode
  actions?: React.ReactNode
  toolbar?: React.ReactNode
  contained?: boolean
}) {
  return (
    <header className="shrink-0 border-b border-hairline bg-background">
      <div
        className={cn(
          "flex min-h-14 flex-wrap items-center gap-x-4 gap-y-2 px-4 py-2.5 sm:px-6",
          contained && CONTAINED,
        )}
      >
        <div className="flex min-w-0 flex-1 basis-48 flex-col gap-0.5">
          <div className="flex min-w-0 items-center gap-2">
            {parent ? (
              <>
                <Link
                  href={parent.href}
                  className="shrink-0 rounded-sm text-[15px] text-text-3 transition-colors hover:text-foreground"
                >
                  {parent.label}
                </Link>
                <ChevronRightIcon aria-hidden className="size-3.5 shrink-0 text-text-3" />
              </>
            ) : null}
            <h1 className="truncate text-[15px] font-medium text-foreground">{title}</h1>
            {status ? <div className="flex shrink-0 items-center gap-1.5">{status}</div> : null}
          </div>
          {description ? <p className="truncate text-[12px] text-text-3">{description}</p> : null}
        </div>
        {actions ? <div className="flex shrink-0 flex-wrap items-center gap-1.5">{actions}</div> : null}
      </div>
      {toolbar ? <div className={cn("px-4 pb-3 sm:px-6", contained && CONTAINED)}>{toolbar}</div> : null}
    </header>
  )
}

/**
 * Frames one page of the console: its page header and, below it, the page body that fills the rest of the
 * content area. The title and description default to the page's sidebar entry.
 */
export function PageFrame({
  title,
  description,
  parent,
  status,
  actions,
  toolbar,
  contained = false,
  children,
}: {
  title?: string
  description?: React.ReactNode
  parent?: PageParent
  status?: React.ReactNode
  actions?: React.ReactNode
  toolbar?: React.ReactNode
  contained?: boolean
  children: React.ReactNode
}) {
  const item = findItem(normalizePath(usePathname()))
  return (
    <>
      <PageHeader
        title={title ?? item?.label ?? "Smart Surveillance"}
        description={description === undefined ? item?.description : description}
        parent={parent}
        status={status}
        actions={actions}
        toolbar={toolbar}
        contained={contained}
      />
      <div className="flex min-h-0 min-w-0 flex-1">{children}</div>
    </>
  )
}

/** The padded, width-limited column of a page that reads as a document, such as Health or Counts. */
export function PageContent({ className, ...props }: React.ComponentProps<"div">) {
  return <div className={cn(CONTAINED, "flex flex-col gap-6 px-4 py-4 sm:px-6 sm:py-6", className)} {...props} />
}

/** Cards in two equal columns that flow in reading order, with an odd last card across both columns. */
export function CardGrid({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      className={cn(
        "grid grid-cols-1 gap-3 @2xl:grid-cols-2 @2xl:[&>*:last-child:nth-child(odd)]:col-span-2",
        className,
      )}
      {...props}
    />
  )
}

/**
 * A row of filters for a page header's toolbar. It wraps on wide screens and scrolls sideways on phones, so the
 * header stays one row tall there.
 */
export function ToolbarRow({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      className={cn(
        "-mx-4 -my-1 flex items-center gap-2 overflow-x-auto px-4 py-1 [scrollbar-width:none] *:shrink-0 sm:-mx-6 sm:px-6 md:mx-0 md:flex-wrap md:overflow-visible md:px-0",
        className,
      )}
      {...props}
    />
  )
}
