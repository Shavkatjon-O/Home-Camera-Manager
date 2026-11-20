import type { Metadata } from "next"
import { notFound } from "next/navigation"
import { createRelativeLink } from "fumadocs-ui/mdx"
import { DocsBody, DocsDescription, DocsPage, DocsTitle, EditOnGitHub } from "fumadocs-ui/layouts/docs/page"

import { OpenAPIPage } from "@/components/api-page"
import { getMDXComponents } from "@/components/mdx"
import { openapi } from "@/lib/openapi"
import { repository } from "@/lib/site"
import { source } from "@/lib/source"

/**
 * One documentation page, from its MDX file or the API reference.
 *
 * @param props The props.
 * @param props.params The language and the page's path.
 * @returns The page.
 */
export default async function Page({ params }: PageProps<"/[lang]/docs/[[...slug]]">) {
  const { lang, slug } = await params
  const page = source.getPage(slug, lang)
  if (!page) notFound()

  const MDX = page.data.body
  const generated = page.path.startsWith(`${lang}/reference/api/`) || page.path === `${lang}/architecture.mdx`
  const editUrl = generated
    ? undefined
    : `https://github.com/${repository.owner}/${repository.name}/blob/${repository.branch}/apps/docs/content/docs/${page.path}`

  return (
    <DocsPage toc={page.data.toc} full={page.data.full}>
      <DocsTitle>{page.data.title}</DocsTitle>
      <DocsDescription>{page.data.description}</DocsDescription>
      <DocsBody>
        <MDX
          components={getMDXComponents({
            a: createRelativeLink(source, page),
            OpenAPIPage: async (props) => <OpenAPIPage {...await openapi.preloadOpenAPIPage(page)} {...props} />,
          })}
        />
      </DocsBody>
      {editUrl ? <EditOnGitHub href={editUrl} /> : null}
    </DocsPage>
  )
}

/**
 * Build every documentation page of every language.
 *
 * @returns The language and path parameters.
 */
export function generateStaticParams() {
  return source.generateParams()
}

/**
 * Title and description of a page.
 *
 * @param props The props.
 * @param props.params The language and the page's path.
 * @returns The page's metadata.
 */
export async function generateMetadata({ params }: PageProps<"/[lang]/docs/[[...slug]]">): Promise<Metadata> {
  const { lang, slug } = await params
  const page = source.getPage(slug, lang)
  if (!page) notFound()
  return { title: page.data.title, description: page.data.description }
}
