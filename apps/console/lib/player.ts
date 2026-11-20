export interface VideoStreamElement extends HTMLElement {
  mode: string
  media: string
  background: boolean
  src: string
  video: HTMLVideoElement | null
  ondisconnect: () => void
}

export const STREAM_ERROR_EVENT = "stream-error"

const PLAYER_URL = "/go2rtc/video-rtc.js"
const LOAD_TIMEOUT_MS = 15000

function playerScript(url: string): string {
  return `import { VideoRTC } from ${JSON.stringify(url)};
if (!customElements.get("video-stream")) {
  customElements.define("video-stream", class extends VideoRTC {
    oninit() {
      super.oninit();
      this.video.muted = true;
      this.video.autoplay = true;
      this.video.controls = false;
      this.video.setAttribute("playsinline", "");
    }
    codecs(isSupported) {
      return super.codecs((type) => !/hvc1|hev1/i.test(type) && isSupported(type));
    }
    onopen() {
      const modes = super.onopen();
      this.onmessage.status = (msg) => {
        if (msg.type === "error") {
          this.dispatchEvent(new CustomEvent(${JSON.stringify(STREAM_ERROR_EVENT)}, { detail: String(msg.value) }));
        }
      };
      return modes;
    }
  });
}
`
}

let pending: Promise<void> | null = null
let attempts = 0

export function loadPlayer(): Promise<void> {
  if (typeof window === "undefined") return Promise.reject(new Error("The player needs a browser"))
  if (customElements.get("video-stream")) return Promise.resolve()
  if (pending) return pending
  attempts += 1
  const url = attempts === 1 ? PLAYER_URL : `${PLAYER_URL}?attempt=${attempts}`
  pending = new Promise<void>((resolve, reject) => {
    const script = document.createElement("script")
    script.type = "module"
    script.dataset.player = "go2rtc"
    let settled = false
    const fail = (message: string) => {
      if (settled) return
      settled = true
      window.clearTimeout(timer)
      script.remove()
      pending = null
      reject(new Error(message))
    }
    const timer = window.setTimeout(() => fail("The player took too long to load"), LOAD_TIMEOUT_MS)
    script.addEventListener("error", () => fail("The player could not be loaded"))
    customElements.whenDefined("video-stream").then(() => {
      if (settled) return
      settled = true
      window.clearTimeout(timer)
      resolve()
    })
    script.textContent = playerScript(url)
    document.head.appendChild(script)
  })
  return pending
}

export function streamSocketUrl(stream: string): string {
  const scheme = window.location.protocol === "https:" ? "wss" : "ws"
  return `${scheme}://${window.location.host}/go2rtc/api/ws?src=${encodeURIComponent(stream)}`
}

export function frameUrl(stream: string): string {
  return `/go2rtc/api/frame.jpeg?src=${encodeURIComponent(stream)}`
}
