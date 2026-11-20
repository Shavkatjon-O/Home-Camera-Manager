import type { Metadata } from "next"

import { NotificationsView } from "@/components/business/notifications-view"

export const metadata: Metadata = { title: "Notifications" }

/**
 * Route page for the notification channels.
 *
 * @returns The notifications view.
 */
export default function NotificationsPage() {
  return <NotificationsView />
}
