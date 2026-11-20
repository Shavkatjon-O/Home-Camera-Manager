import type { Metadata, Viewport } from "next"
import { GeistMono } from "geist/font/mono"
import { GeistSans } from "geist/font/sans"
import { i18nProvider } from "fumadocs-ui/i18n"

import { Provider } from "@/components/provider"
import { i18n } from "@/lib/i18n"
import { translations } from "@/lib/layout.shared"
import { productName, systemName } from "@/lib/site"

import "../global.css"

/** Title template and description shared by every page. */
export const metadata: Metadata = {
  title: {
    default: `${productName} Docs`,
    template: `%s - ${productName} Docs`,
  },
  description: `Documentation of ${systemName}: products, cameras, analytics, deployment and the API.`,
}

/** Viewport and theme colour, which follow the console's surfaces. */
export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: [
    { media: "(prefers-color-scheme: dark)", color: "#0a0a0a" },
    { media: "(prefers-color-scheme: light)", color: "#fafafa" },
  ],
}

/**
 * The site's root for one language: fonts, theme, search and interface text.
 *
 * @param props The props.
 * @param props.params The language of the page.
 * @param props.children The page.
 * @returns The document.
 */
export default async function LanguageLayout({ params, children }: LayoutProps<"/[lang]">) {
  const { lang } = await params
  return (
    <html lang={lang} className={`${GeistSans.variable} ${GeistMono.variable}`} suppressHydrationWarning>
      <body className="flex min-h-screen flex-col antialiased">
        <Provider i18n={i18nProvider(translations, lang)}>{children}</Provider>
      </body>
    </html>
  )
}

/**
 * Build one copy of the site per language.
 *
 * @returns The language parameters.
 */
export function generateStaticParams() {
  return i18n.languages.map((lang) => ({ lang }))
}
