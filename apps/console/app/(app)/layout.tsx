import { EventsProvider } from "@/components/events/events-provider"
import { AppShell } from "@/components/shell/app-shell"
import { SessionProvider } from "@/components/shell/session"

/** Wraps every signed-in page in the session, the live event stream and the application shell. */
export default function AppLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <SessionProvider>
      <EventsProvider>
        <AppShell>{children}</AppShell>
      </EventsProvider>
    </SessionProvider>
  )
}
