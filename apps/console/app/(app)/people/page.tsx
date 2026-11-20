import type { Metadata } from "next"

import { PeoplePage } from "@/components/people/people-view"

export const metadata: Metadata = { title: "People" }

export default function Page() {
  return <PeoplePage />
}
