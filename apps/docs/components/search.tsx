"use client"

import { useStaticSearch } from "fumadocs-core/search/client"
import {
  SearchDialog,
  SearchDialogClose,
  SearchDialogContent,
  SearchDialogHeader,
  SearchDialogIcon,
  SearchDialogInput,
  SearchDialogList,
  SearchDialogOverlay,
  type SharedProps,
} from "fumadocs-ui/components/dialog/search"
import { useI18n } from "fumadocs-ui/contexts/i18n"

import { withBasePath } from "@/lib/site"

/**
 * Search over the index the build exports, run in the browser, so the static site needs no search server.
 *
 * @param props Open state and its setter from the layout.
 * @returns The search dialog.
 */
export default function StaticSearchDialog(props: SharedProps) {
  const { locale } = useI18n()
  const search = useStaticSearch({ from: withBasePath("/api/search"), locale })

  return (
    <SearchDialog {...search} {...props}>
      <SearchDialogOverlay />
      <SearchDialogContent>
        <SearchDialogHeader>
          <SearchDialogIcon />
          <SearchDialogInput />
          <SearchDialogClose />
        </SearchDialogHeader>
        <SearchDialogList />
      </SearchDialogContent>
    </SearchDialog>
  )
}
