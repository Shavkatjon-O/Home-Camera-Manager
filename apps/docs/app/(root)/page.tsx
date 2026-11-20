import { i18n } from "@/lib/i18n"
import { withBasePath } from "@/lib/site"

/**
 * The site's entry address, which forwards to the default language, since a static site cannot negotiate one.
 *
 * @returns A page that redirects at once, with a link for browsers that ignore the refresh.
 */
export default function RootPage() {
  const target = withBasePath(`/${i18n.defaultLanguage}/`)
  return (
    <>
      <meta httpEquiv="refresh" content={`0; url=${target}`} />
      <p style={{ fontFamily: "system-ui, sans-serif", padding: 24 }}>
        <a href={target}>Open the documentation</a>
      </p>
    </>
  )
}
