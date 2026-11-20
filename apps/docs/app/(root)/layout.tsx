import type { ReactNode } from "react"

import "../global.css"

/**
 * The bare document of the site's entry address, which only forwards to a language.
 *
 * @param props The props.
 * @param props.children The forwarding page.
 * @returns The document.
 */
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
