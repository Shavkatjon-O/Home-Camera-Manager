import { HomeLayout } from "fumadocs-ui/layouts/home"

import { baseOptions } from "@/lib/layout.shared"

/**
 * The layout of the landing page: the shared navigation bar without the docs sidebar.
 *
 * @param props The props.
 * @param props.params The language of the page.
 * @param props.children The page.
 * @returns The layout around the page.
 */
export default async function Layout({ params, children }: LayoutProps<"/[lang]">) {
  const { lang } = await params
  return <HomeLayout {...baseOptions(lang)}>{children}</HomeLayout>
}
