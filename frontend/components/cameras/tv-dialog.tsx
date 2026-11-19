"use client"

import * as React from "react"
import { toast } from "sonner"

import { Spinner } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { api, errorMessage, isAbort } from "@/lib/api"
import { formatDateTime } from "@/lib/format"
import type { TvDevice } from "@/lib/types"

const CODE_LENGTH = 6

function TvRow({ device, onRevoked }: { device: TvDevice; onRevoked: () => void }) {
  const [confirming, setConfirming] = React.useState(false)
  const [busy, setBusy] = React.useState(false)

  const revoke = async () => {
    setBusy(true)
    try {
      await api.revokeTvDevice(device.uuid)
      toast.success(`Revoked ${device.name}`)
      onRevoked()
    } catch (err) {
      toast.error(errorMessage(err))
      setBusy(false)
    }
  }

  return (
    <li className="flex items-center gap-3 py-2.5">
      <div className="flex min-w-0 flex-1 flex-col gap-0.5">
        <span className="truncate text-[13px] text-foreground">{device.name}</span>
        <span className="font-data text-[11px] text-text-3">
          Paired {formatDateTime(device.created_at)}, last seen{" "}
          {device.last_seen_at ? formatDateTime(device.last_seen_at) : "never"}
        </span>
      </div>
      {confirming ? (
        <div className="flex shrink-0 items-center gap-1">
          <Button variant="outline" size="xs" onClick={() => setConfirming(false)} disabled={busy}>
            Keep
          </Button>
          <Button variant="destructive" size="xs" onClick={revoke} disabled={busy}>
            {busy ? <Spinner className="size-3 text-white" /> : null}
            Revoke
          </Button>
        </div>
      ) : (
        <Button variant="outline" size="xs" className="shrink-0" onClick={() => setConfirming(true)}>
          Revoke
        </Button>
      )}
    </li>
  )
}

function TvPanel() {
  const [devices, setDevices] = React.useState<TvDevice[] | null>(null)
  const [listError, setListError] = React.useState<string | null>(null)
  const [reload, setReload] = React.useState(0)
  const [code, setCode] = React.useState("")
  const [codeError, setCodeError] = React.useState<string | null>(null)
  const [pairing, setPairing] = React.useState(false)

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .listTvDevices(controller.signal)
      .then((result) => {
        setDevices(result.items)
        setListError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setListError(errorMessage(err))
      })
    return () => controller.abort()
  }, [reload])

  const pair = async (event: React.FormEvent) => {
    event.preventDefault()
    if (code.length !== CODE_LENGTH) {
      setCodeError("Enter the 6 digits the TV shows")
      return
    }
    setPairing(true)
    setCodeError(null)
    try {
      const device = await api.approveTvPairing(code)
      toast.success(`Paired ${device.name}`)
      setCode("")
      setReload((value) => value + 1)
    } catch (err) {
      setCodeError(errorMessage(err))
    } finally {
      setPairing(false)
    }
  }

  return (
    <>
      <DialogHeader>
        <DialogTitle>TV</DialogTitle>
        <DialogDescription>Pair the Home cameras TV app with the code it shows, or revoke a paired TV.</DialogDescription>
      </DialogHeader>
      <DialogBody className="flex flex-col gap-5">
        <form onSubmit={pair} noValidate className="flex flex-col gap-1.5">
          <Label htmlFor="tv-code">Pairing code</Label>
          <div className="flex items-center gap-2">
            <Input
              id="tv-code"
              value={code}
              onChange={(event) => {
                setCode(event.target.value.replace(/\D/g, "").slice(0, CODE_LENGTH))
                setCodeError(null)
              }}
              placeholder="000000"
              inputMode="numeric"
              autoComplete="one-time-code"
              autoFocus
              className="w-32 font-data tracking-[0.3em]"
              aria-invalid={Boolean(codeError)}
            />
            <Button type="submit" disabled={pairing}>
              {pairing ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
              Pair
            </Button>
          </div>
          {codeError ? (
            <p role="alert" className="text-[12px] text-danger">
              {codeError}
            </p>
          ) : (
            <p className="text-[12px] text-text-3">The code renews on the TV every 10 minutes.</p>
          )}
        </form>
        <section className="flex flex-col">
          <span className="border-b border-hairline pb-2 text-xs text-text-3">Paired TVs</span>
          {devices === null ? (
            <div className="flex items-center gap-2 py-3 text-[13px] text-text-3">
              {listError ? <span className="text-danger">{listError}</span> : <Spinner className="size-3.5" />}
            </div>
          ) : devices.length === 0 ? (
            <p className="py-3 text-[13px] text-text-3">No TV is paired yet.</p>
          ) : (
            <ul className="flex flex-col divide-y divide-hairline">
              {devices.map((device) => (
                <TvRow key={device.uuid} device={device} onRevoked={() => setReload((value) => value + 1)} />
              ))}
            </ul>
          )}
        </section>
      </DialogBody>
    </>
  )
}

export function TvDialog({ open, onOpenChange }: { open: boolean; onOpenChange: (open: boolean) => void }) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <TvPanel />
      </DialogContent>
    </Dialog>
  )
}
