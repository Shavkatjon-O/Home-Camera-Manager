import { posix } from "node:path"
import type { ComponentProps, FC } from "react"
import defaultMdxComponents from "fumadocs-ui/mdx"

import { source } from "@/lib/source"

type DocsPage = NonNullable<ReturnType<typeof source.getPage>>

/**
 * Build the link component of a page, which turns links to other MDX files, such as ../guides/console.mdx, into
 * the address of that page in the page's language. Fumadocs keeps the language folder in a page's path, so the
 * folder is taken off before the link is resolved.
 *
 * @param page The page whose links are resolved.
 * @returns The link component.
 */
export function relativeLink(page: DocsPage): FC<ComponentProps<"a">> {
  const Anchor = defaultMdxComponents.a as FC<ComponentProps<"a">>
  const language = page.locale ?? ""
  const folder = posix.dirname(page.path)
  const dir = language && (folder === language || folder.startsWith(`${language}/`)) ? folder.slice(language.length + 1) : folder
  return function RelativeLink({ href, ...props }) {
    if (href && (href.startsWith("./") || href.startsWith("../"))) {
      const target = source.getPageByHref(href, { dir, language: page.locale })
      if (target) return <Anchor href={target.hash ? `${target.page.url}#${target.hash}` : target.page.url} {...props} />
    }
    return <Anchor href={href} {...props} />
  }
}
