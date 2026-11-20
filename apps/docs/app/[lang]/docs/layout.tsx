import { DocsLayout } from "fumadocs-ui/layouts/docs"

import { baseOptions } from "@/lib/layout.shared"
import { source } from "@/lib/source"

/**
 * The documentation layout: navigation bar, sidebar from the page tree and search.
 *
 * @param props The props.
 * @param props.params The language of the page.
 * @param props.children The page.
 * @returns The layout around the page.
 */
export default async function Layout({ params, children }: LayoutProps<"/[lang]/docs">) {
  const { lang } = await params
  return (
    <DocsLayout tree={source.getPageTree(lang)} {...baseOptions(lang)}>
      {children}
    </DocsLayout>
  )
}
