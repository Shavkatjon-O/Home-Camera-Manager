"use client"

import * as React from "react"
import { BellRingIcon, SendIcon, Trash2Icon } from "lucide-react"
import { toast } from "sonner"

import { humanise } from "@/components/business/labels"
import { PageError, PageLoading, PageRestricted } from "@/components/business/panels"
import { useCurrentSite } from "@/components/business/use-current-site"
import { PageContent, PageFrame } from "@/components/shell/page-frame"
import { Chip, EmptyState } from "@/components/shell/primitives"
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ApiError, api, errorMessage, isAbort } from "@/lib/api"
import { formatDateTime } from "@/lib/format"
import type { TelegramChat, TelegramChatList, TelegramLink } from "@/lib/types"

/**
 * The notification channels page: linked Telegram chats, link creation, test messages and removal.
 *
 * @returns The page inside the application frame.
 */
export function NotificationsView() {
  const { site, loaded, error: siteError, isManager } = useCurrentSite()
  const [list, setList] = React.useState<TelegramChatList | null>(null)
  const [error, setError] = React.useState<ApiError | Error | null>(null)
  const [reload, setReload] = React.useState(0)
  const [link, setLink] = React.useState<TelegramLink | null>(null)
  const [linking, setLinking] = React.useState(false)
  const [removing, setRemoving] = React.useState<TelegramChat | null>(null)
  const [busy, setBusy] = React.useState<string | null>(null)

  React.useEffect(() => {
    if (!isManager) return
    const controller = new AbortController()
    api
      .listTelegramChats(controller.signal)
      .then((data) => {
        setList(data)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(err instanceof Error ? err : new Error(errorMessage(err)))
      })
    return () => controller.abort()
  }, [isManager, reload])

  const refresh = () => setReload((value) => value + 1)

  const createLink = async () => {
    setLinking(true)
    try {
      setLink(await api.createTelegramLink())
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setLinking(false)
    }
  }

  const sendTest = async (chat: TelegramChat) => {
    setBusy(chat.uuid)
    try {
      await api.testTelegramChat(chat.uuid)
      toast.success("Test message sent")
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(null)
    }
  }

  const remove = async () => {
    if (!removing) return
    const chat = removing
    setBusy(chat.uuid)
    try {
      await api.removeTelegramChat(chat.uuid)
      setRemoving(null)
      refresh()
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(null)
    }
  }

  let content: React.ReactNode
  if (!loaded) content = <PageLoading label="Loading notifications" />
  else if (siteError) content = <PageError title="Cannot load notifications" message={siteError} />
  else if (!site) content = <PageRestricted title="No site yet" message="Pair a connector or add a site first." />
  else if (!isManager) {
    content = <PageRestricted title="Notifications are restricted" message="Only admins and owners manage notification channels." />
  } else if (error instanceof ApiError && error.status === 403 && error.code === "feature_not_in_plan") {
    content = <PageRestricted title="Telegram alerts are not in your plan" message="The plan does not include Telegram alerts." />
  } else if (error instanceof ApiError && error.status === 403) {
    content = <PageRestricted title="Notifications are restricted" message="Only admins and owners manage notification channels." />
  } else if (!list && error) {
    content = <PageError title="Cannot load notifications" message={error.message} onRetry={refresh} />
  } else if (!list) {
    content = <PageLoading label="Loading notifications" />
  } else if (!list.available) {
    content = (
      <EmptyState icon={<BellRingIcon />} title="Telegram alerts are not set up">
        <span>Telegram alerts are not set up on this server.</span>
      </EmptyState>
    )
  } else {
    content = (
      <PageContent>
        <section className="flex flex-col gap-3" aria-labelledby="link-title">
          <h2 id="link-title" className="text-xs text-text-3">
            Link a chat
          </h2>
          <div className="flex flex-wrap items-center gap-2">
            <Button onClick={() => void createLink()} disabled={linking}>
              Create links
            </Button>
            <Button variant="outline" onClick={refresh}>
              Refresh list
            </Button>
          </div>
          {link ? (
            <div className="flex flex-col gap-2 rounded-lg border border-hairline p-3 text-[13px]">
              <div className="flex flex-wrap gap-2">
                <Button asChild variant="outline">
                  <a href={link.url} target="_blank" rel="noreferrer">
                    Open in Telegram
                  </a>
                </Button>
                <Button asChild variant="outline">
                  <a href={link.group_url} target="_blank" rel="noreferrer">
                    Add to a group
                  </a>
                </Button>
              </div>
              <p className="font-data text-[11px] text-text-3">
                Bot {link.bot}. The links work once and expire at {formatDateTime(link.expires_at)}. Refresh the list
                after linking.
              </p>
            </div>
          ) : null}
        </section>
        <section className="flex flex-col gap-2" aria-labelledby="chats-title">
          <h2 id="chats-title" className="text-xs text-text-3">
            Linked chats
          </h2>
          <div className="overflow-x-auto rounded-lg border border-hairline">
            <Table>
              <TableHeader>
                <TableRow className="hover:bg-transparent">
                  <TableHead>Title</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>State</TableHead>
                  <TableHead>Linked</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {list.items.length > 0 ? (
                  list.items.map((chat) => (
                    <TableRow key={chat.uuid}>
                      <TableCell>{chat.title ?? "Private chat"}</TableCell>
                      <TableCell className="text-text-2">{humanise(chat.chat_type)}</TableCell>
                      <TableCell>
                        {chat.blocked ? (
                          <Chip className="text-danger">Blocked</Chip>
                        ) : chat.enabled ? (
                          <Chip>Enabled</Chip>
                        ) : (
                          <Chip>Disabled</Chip>
                        )}
                      </TableCell>
                      <TableCell className="font-data text-xs text-text-2">{formatDateTime(chat.created_at)}</TableCell>
                      <TableCell>
                        <div className="flex justify-end gap-1">
                          <Button
                            variant="outline"
                            size="sm"
                            disabled={busy === chat.uuid}
                            onClick={() => void sendTest(chat)}
                          >
                            <SendIcon />
                            Send test
                          </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            disabled={busy === chat.uuid}
                            onClick={() => setRemoving(chat)}
                          >
                            <Trash2Icon />
                            Remove
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow className="hover:bg-transparent">
                    <TableCell colSpan={5} className="text-center text-[13px] text-text-3">
                      No chats linked yet
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </section>
      </PageContent>
    )
  }

  return (
    <PageFrame contained>
      <main className="@container min-h-0 min-w-0 flex-1 overflow-y-auto">{content}</main>
      <AlertDialog open={removing !== null} onOpenChange={(open) => (open ? undefined : setRemoving(null))}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Remove this chat</AlertDialogTitle>
            <AlertDialogDescription>
              {removing?.title ?? "This chat"} stops receiving alerts. You can link it again later.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel asChild>
              <Button variant="outline">Cancel</Button>
            </AlertDialogCancel>
            <Button variant="destructive" onClick={() => void remove()}>
              Remove
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </PageFrame>
  )
}
