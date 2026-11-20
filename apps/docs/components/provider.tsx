"use client"

import type { ReactNode } from "react"
import { RootProvider } from "fumadocs-ui/provider/next"
import type { I18nProviderProps } from "fumadocs-ui/contexts/i18n"

import StaticSearchDialog from "@/components/search"

/**
 * Theme, search and language context for every page.
 *
 * @param props The props.
 * @param props.i18n Language and interface text of the page.
 * @param props.children The page.
 * @returns The page inside its providers.
 */
export function Provider({ i18n, children }: { i18n: I18nProviderProps; children: ReactNode }) {
  return (
    <RootProvider i18n={i18n} search={{ SearchDialog: StaticSearchDialog }} theme={{ defaultTheme: "system" }}>
      {children}
    </RootProvider>
  )
}
