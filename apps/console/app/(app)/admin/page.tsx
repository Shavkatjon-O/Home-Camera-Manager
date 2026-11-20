import type { Metadata } from "next"

import { AdminView } from "@/components/business/admin-view"

export const metadata: Metadata = { title: "Platform admin" }

/**
 * Route page for the platform admin.
 *
 * @returns The admin view.
 */
export default function AdminPage() {
  return <AdminView />
}
