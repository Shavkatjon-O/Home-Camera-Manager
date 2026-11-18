import { SessionProvider } from "@/components/shell/session"

export default function AppLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <SessionProvider>{children}</SessionProvider>
}
