import type { Metadata } from "next"

import { DiscoverView } from "@/components/discover/discover-view"

export const metadata: Metadata = { title: "Add camera" }

/** Route of the Add camera page. */
export default function DiscoverPage() {
  return <DiscoverView />
}
