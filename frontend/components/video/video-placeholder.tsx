import { VideoOffIcon } from "lucide-react"

export function VideoPlaceholder({ title, detail }: { title: string; detail?: string | null }) {
  return (
    <div className="absolute inset-0 flex flex-col items-center justify-center gap-2 bg-black p-4 text-center">
      <VideoOffIcon aria-hidden className="size-5 text-white/40" />
      <div className="text-[12px] text-white/70">{title}</div>
      {detail ? (
        <div className="line-clamp-2 max-w-sm font-mono text-[11px] break-words text-white/40">{detail}</div>
      ) : null}
    </div>
  )
}
