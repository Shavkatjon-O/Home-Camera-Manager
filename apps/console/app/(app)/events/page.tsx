import type { Metadata } from "next"

import { EventsPage } from "@/components/events/events-view"

export const metadata: Metadata = { title: "Events" }

export default function Page() {
  return <EventsPage />
}
