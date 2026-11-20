import type { BaseLayoutProps } from "fumadocs-ui/layouts/shared"
import { uiTranslations } from "fumadocs-ui/i18n"

import { Logo } from "@/components/logo"
import { i18n } from "@/lib/i18n"
import { repositoryUrl } from "@/lib/site"

/** Interface text of the layouts in every language of the site. */
export const translations = i18n
  .translations()
  .extend(uiTranslations())
  .add({
    en: {
      displayName: "English",
    },
  })

/**
 * Options every layout of the site shares.
 *
 * @param lang Language of the page.
 * @returns The navigation title, links and language settings.
 */
export function baseOptions(lang: string): BaseLayoutProps {
  return {
    nav: {
      title: <Logo />,
      url: `/${lang}/`,
    },
    githubUrl: repositoryUrl,
    links: [
      { text: "Docs", url: `/${lang}/docs/`, active: "nested-url" },
      { text: "API", url: `/${lang}/docs/reference/api/`, active: "nested-url" },
      { text: "Changelog", url: `/${lang}/docs/changelog/`, active: "url" },
    ],
  }
}
