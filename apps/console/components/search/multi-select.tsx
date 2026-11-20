"use client"

import { CheckIcon, ChevronDownIcon } from "lucide-react"
import { DropdownMenu } from "radix-ui"

import { ColorDot } from "@/components/people/face-parts"
import { cn } from "@/lib/utils"

export interface MultiOption {
  value: string
  label: string
  detail?: string | null
  color?: string | null
}

const itemClass =
  "relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-[13px] outline-hidden select-none focus:bg-surface-2 data-[highlighted]:bg-surface-2 data-[disabled]:pointer-events-none data-[disabled]:opacity-50"

function Indicator() {
  return (
    <span className="absolute right-2 flex size-3.5 items-center justify-center">
      <DropdownMenu.ItemIndicator>
        <CheckIcon className="size-3.5" />
      </DropdownMenu.ItemIndicator>
    </span>
  )
}

export function MultiSelect({
  label,
  allLabel,
  noun,
  options,
  value,
  onChange,
  className,
}: {
  label: string
  allLabel: string
  noun: { one: string; many: string }
  options: MultiOption[]
  value: string[]
  onChange: (value: string[]) => void
  className?: string
}) {
  const single = value.length === 1 ? options.find((option) => option.value === value[0]) : undefined
  const summary =
    value.length === 0
      ? allLabel
      : single
        ? single.label
        : `${value.length} ${value.length === 1 ? noun.one : noun.many}`

  const toggle = (option: string, checked: boolean) => {
    if (checked) onChange(value.includes(option) ? value : [...value, option])
    else onChange(value.filter((item) => item !== option))
  }

  return (
    <DropdownMenu.Root modal={false}>
      <DropdownMenu.Trigger
        aria-label={`${label}: ${summary}`}
        className={cn(
          "flex h-8 min-w-0 items-center justify-between gap-2 rounded-md border border-input bg-transparent px-2.5 text-[13px] whitespace-nowrap text-foreground transition-colors outline-none hover:border-hairline-strong data-[state=open]:border-hairline-strong [&_svg]:pointer-events-none [&_svg]:shrink-0",
          className,
        )}
      >
        <span className={cn("truncate", value.length === 0 && "text-text-2")}>{summary}</span>
        <ChevronDownIcon aria-hidden className="size-3.5 text-text-3" />
      </DropdownMenu.Trigger>
      <DropdownMenu.Portal>
        <DropdownMenu.Content
          align="start"
          sideOffset={4}
          className="z-50 max-h-(--radix-dropdown-menu-content-available-height) max-w-[min(20rem,calc(100vw-2rem))] min-w-(--radix-dropdown-menu-trigger-width) overflow-x-hidden overflow-y-auto rounded-md border border-hairline bg-popover p-1 text-popover-foreground shadow-xl data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:animate-in data-[state=open]:fade-in-0"
        >
          <DropdownMenu.CheckboxItem
            checked={value.length === 0}
            onCheckedChange={() => onChange([])}
            onSelect={(event) => event.preventDefault()}
            className={itemClass}
          >
            <Indicator />
            <span className="truncate">{allLabel}</span>
          </DropdownMenu.CheckboxItem>
          {options.length > 0 ? <DropdownMenu.Separator className="-mx-1 my-1 h-px bg-hairline" /> : null}
          {options.map((option) => (
            <DropdownMenu.CheckboxItem
              key={option.value}
              checked={value.includes(option.value)}
              onCheckedChange={(checked) => toggle(option.value, checked === true)}
              onSelect={(event) => event.preventDefault()}
              className={itemClass}
            >
              <Indicator />
              {option.color !== undefined ? <ColorDot color={option.color} /> : null}
              <span className="min-w-0 truncate">{option.label}</span>
              {option.detail ? (
                <span className="min-w-0 shrink-0 truncate text-[12px] text-text-3">{option.detail}</span>
              ) : null}
            </DropdownMenu.CheckboxItem>
          ))}
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  )
}
