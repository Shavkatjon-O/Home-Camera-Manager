# Home Cameras

Single-window live view of the home EZVIZ cameras, security-wall style.

## What it is

- **go2rtc** pulls each camera's RTSP feed and, because the cameras stream
  H.265 (which browsers cannot play), transcodes to H.264 on demand.
- **nginx** serves a dark grid front-end and proxies the go2rtc API/WebSocket.

Cameras (EZVIZ CS-H3, 5MP, main stream `/Streaming/Channels/101`):

| Stream | Camera | IP |
| --- | --- | --- |
| cam_a | Camera A | 192.168.1.104 |
| cam_b | Camera B | 192.168.1.106 |

A third camera (currently on a SIM link) can be added to `go2rtc.yaml` once it
joins the Wi-Fi. `python3 discover.py` finds every camera that answers
Hikvision SADP or ONVIF discovery and says whether its RTSP port is open; run
it after the camera is on the Wi-Fi to get its address. EZVIZ ships local
RTSP switched off on most models: enable it in the app under LAN Live View,
camera, Settings, Local Service Settings. Battery and 4G models are not in
EZVIZ's ONVIF list and idle with all services closed.

## Run

    cp .env.example .env      # then put the EZVIZ image-encryption password in it
    docker compose up -d

Open http://localhost:8750 on this machine.

Stop with `docker compose down`.

## Front-end

- Grid / Stacked layout toggle, whole-wall fullscreen, per-tile fullscreen on
  double-click, mute toggle (starts muted so autoplay is allowed), live clock.
- Edit the `CAMERAS` list in `web/app.js` to add or rename tiles.

## Config notes

- Credentials live only in `.env` (gitignored). `go2rtc.yaml` reads
  `${CAMERA_PASSWORD}`; both cameras currently share one password.
- The grid uses the 5MP main stream. For lighter CPU, point a stream at the
  sub stream `/Streaming/Channels/102` in `go2rtc.yaml`.
- Playback transport is MSE (H.264 over the WebSocket). WebRTC is available in
  go2rtc for lower latency but needs media-port/candidate setup; not enabled.
- Ports: front-end on 127.0.0.1:8750; go2rtc stays internal to the compose
  network.
