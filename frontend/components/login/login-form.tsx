"use client"

import * as React from "react"
import { useRouter } from "next/navigation"
import { CctvIcon } from "lucide-react"

import { Spinner } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { ApiError, LOGIN_PATH, api, errorMessage } from "@/lib/api"

function nextPath(): string {
  const value = new URLSearchParams(window.location.search).get("next")
  if (!value || !value.startsWith("/") || value.startsWith("//") || value.startsWith(LOGIN_PATH)) return "/"
  return value
}

export function LoginForm() {
  const router = useRouter()
  const [username, setUsername] = React.useState("")
  const [password, setPassword] = React.useState("")
  const [busy, setBusy] = React.useState(false)
  const [error, setError] = React.useState<string | null>(null)

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .me(false, controller.signal)
      .then(() => router.replace(nextPath()))
      .catch(() => undefined)
    return () => controller.abort()
  }, [router])

  const submit = async (event: React.FormEvent) => {
    event.preventDefault()
    if (!username.trim() || !password) {
      setError("Enter your username and password")
      return
    }
    setBusy(true)
    setError(null)
    try {
      await api.login(username.trim(), password)
      router.replace(nextPath())
    } catch (err) {
      setBusy(false)
      setPassword("")
      if (err instanceof ApiError && err.status === 401) setError("Wrong username or password")
      else setError(errorMessage(err))
    }
  }

  return (
    <main className="flex h-dvh items-center justify-center overflow-y-auto bg-background px-4">
      <form
        onSubmit={submit}
        noValidate
        className="flex w-full max-w-[340px] flex-col gap-5 rounded-lg border border-hairline bg-surface p-6"
      >
        <div className="flex flex-col gap-3">
          <CctvIcon aria-hidden className="size-5 text-text-2" />
          <h1 className="text-[17px] font-medium text-foreground">Sign in</h1>
        </div>
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="username">Username</Label>
          <Input
            id="username"
            name="username"
            autoComplete="username"
            autoCapitalize="none"
            spellCheck={false}
            autoFocus
            value={username}
            onChange={(event) => setUsername(event.target.value)}
            aria-invalid={Boolean(error)}
          />
        </div>
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="password">Password</Label>
          <Input
            id="password"
            name="password"
            type="password"
            autoComplete="current-password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            aria-invalid={Boolean(error)}
          />
        </div>
        {error ? (
          <p role="alert" className="text-[13px] text-danger">
            {error}
          </p>
        ) : null}
        <Button type="submit" disabled={busy} className="h-9">
          {busy ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
          Sign in
        </Button>
      </form>
    </main>
  )
}
