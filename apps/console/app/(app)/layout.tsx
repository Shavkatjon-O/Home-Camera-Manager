import { EventsProvider } from "@/components/events/events-provider"
import { SessionProvider } from "@/components/shell/session"

export default function AppLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <SessionProvider>
      <EventsProvider>{children}</EventsProvider>
    </SessionProvider>
  )
}
