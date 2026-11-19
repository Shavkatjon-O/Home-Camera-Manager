# Home cameras

A web app for the home IP cameras: register cameras, watch one camera large, watch all of them at once as a security wall, find cameras on the network and drive PTZ cameras. An Android TV app in tv/ shows the same wall on the living-room TV.

## Services

| Service | Image | Role |
|---|---|---|
| postgres | postgres:17.6-alpine | Users, the camera registry, the floor plans, the network devices and the health samples and outages |
| go2rtc | alexxit/go2rtc:1.9.14-hardware | Pulls each camera's RTSP stream and serves it to the browser, encoding H.264 on the NVIDIA GPU when needed, and serves the composed TV streams over RTSP |
| backend | home-cameras-backend:local | FastAPI: sign in, cameras, discovery, ONVIF PTZ, floor plans, TV pairing, go2rtc stream registration, status probes and the network health prober |
| v380-ptz-1, v380-ptz-2 | home-cameras-v380-bridge:local | One bridge per V380 camera: logs in over the V380 protocol on port 8800, decrypts the stream and serves it as RTSP on 8554 and ONVIF with PTZ on 8080 |
| web | home-cameras-web:local | nginx serving the Next.js static export and proxying the API and the video websocket |

The host needs an NVIDIA GPU with the NVIDIA container toolkit. The web service publishes 8750 on loopback and on the home network address in HC_LAN_BIND, and go2rtc publishes its RTSP port 8554 on HC_LAN_BIND only, so phones and the TV on the home Wi-Fi reach them while the VPN does not.

## Run

```
cp .env.example .env
docker compose up -d --build
```

Set HC_SECRET_KEY to a long random value, HC_TV_RTSP_PASSWORD to another one and HC_LAN_BIND to this machine's home network address before the first start; reserve that address in the router so it does not change. Open http://127.0.0.1:8750 and sign in with HC_ADMIN_USERNAME and HC_ADMIN_PASSWORD; the backend creates that user on first start and never overwrites its password afterwards.

## Pages

- **Wall** - every enabled camera in one grid that fills the screen, sub streams, automatic or forced 1, 2x2 and 3x3 layouts, fullscreen for the wall and for each tile. A camera with several lenses takes one tile per lens.
- **Camera** - one camera on its main or sub stream, its details and status, and a PTZ pad with speed for PTZ cameras; arrow keys and plus or minus drive it while the view has focus. A camera with several lenses shows them side by side or one at a time.
- **Cameras** - the registry: add, edit, delete and the wall order. Detect reads stream paths and PTZ support from the camera over ONVIF. TV pairs a TV by the code it shows and lists or revokes paired TVs.
- **Discover** - scans the home subnet for cameras and opens the add form prefilled for any it finds; a camera counts as added when its address matches a camera's host or device address.
- **Coverage** - plans Wi-Fi coverage on a floor plan: routers, optional walls by material, devices and an optional background image whose shape sets the plan height. A heatmap shows the predicted signal per band with distance and wall loss, the side panel gives the covered share and what each router serves, and Suggest placement moves unlocked routers to the spots that cover the most area. Where no walls are drawn the model assumes open space.
- **Health** - how stable each router and camera is over the last hour, 24 hours or 7 days: a card per target with its status, uptime, typical and p95 latency, outage count, an availability strip and a latency line, and an outage log below. A card opens a side panel with a finer latency chart, the target's outages with the device that caused them, and editing of the device or of how the camera connects.

## Health

The backend probes every enabled network device and camera every HC_HEALTH_INTERVAL_SECONDS with a TCP connect that gives up after 1.5 s, and stores one sample per target with its latency or error. A device is probed on its address and probe port; a camera on its RTSP host and port, or on its device address and the V380 port 8800 when it streams through a bridge, because the bridge container answers even when the camera is gone. Samples older than HC_HEALTH_RETENTION_DAYS are deleted every hour.

Each network device and each camera link names the device it connects through and how: cable, Wi-Fi 2.4 GHz or Wi-Fi 5 GHz. Two failed samples in a row open an outage that starts at the first of them, and the first answer closes it. When the upstream device of a target is down at the start of the target's outage, or goes down within two probe intervals after it, the outage counts as caused upstream and names the top device of that chain, so a camera behind a repeater that dropped with the main router names the main router.

Uptime is the share of answered samples in the range; latency figures cover answered samples only. The 1 hour range shows 1 minute bars, 24 hours 15 minute bars and 7 days 2 hour bars, and the side panel's chart uses 30 second, 5 minute and 30 minute bars. Bars are green when every sample answered, amber when some did, red when none did and grey without samples.

## Cameras

The brand fills the defaults for fields left empty:

| Brand | ONVIF port | Main path | Sub path | PTZ |
|---|---|---|---|---|
| ezviz | 80 | /Streaming/Channels/101 | /Streaming/Channels/102 | no |
| v380 | 8899 | /live/ch00_0 | /live/ch00_1 | yes |
| onvif | given | from ONVIF GetStreamUri | from ONVIF GetStreamUri | from the profile |
| rtsp | none | required | optional | no |

EZVIZ cameras need Local Service Settings switched on in the EZVIZ app; their user is admin and their password is the camera's image-encryption password.

V380 cameras go through their bridge, because their own RTSP server stops answering once a device password is set and some models have no RTSP or ONVIF at all. A bridge needs the camera's address and device ID in V380_PTZ_<n>_HOST and V380_PTZ_<n>_ID, and the shared V380_USERNAME and V380_PASSWORD set as the device login in V380 Pro. Register the camera with brand onvif, host home-cameras-v380-ptz-<n>, device address the camera's own LAN address, RTSP port 8554, ONVIF port 8080, main path /live, no sub path, no login and PTZ on. Another V380 camera gets another bridge service and env group in the same shape. Dual-lens cameras send both pictures stacked in one frame; set Lenses to 2 and the browser crops each band into its own view, with no extra transcoding. Discover lists V380 cameras by their port 8800 even when RTSP is closed.

## Streaming

The backend registers two go2rtc streams per enabled camera, main and sub, each with the camera's RTSP URL followed by an ffmpeg H.264 video transcode without audio, and reconciles go2rtc with the registry on every monitor tick. The browser player asks for H.264 only, so H.265 cameras always play through the transcode. go2rtc.yaml holds no camera streams and is mounted read-only, so camera credentials stay out of files; its ffmpeg h264 template encodes with h264_nvenc while decoding on the CPU. HC_TRANSCODE_HARDWARE adds a go2rtc hardware option such as cuda to every transcode for GPU decoding as well; it stays empty because GPU decoding fails on some bridge streams.

## TV

The TV app pairs once: it asks POST /api/v1/tv/pairings for a 6-digit code, the code is entered under Cameras, TV, and the next poll of GET /api/v1/tv/pairings/{id} hands the TV its device token once. Codes expire after 10 minutes, at most 5 wait at once and each address may ask for 10 a minute. With the token as a Bearer header the TV reads GET /api/v1/tv/config, which lists the wall and every tile with RTSP URLs on HC_LAN_BIND carrying HC_TV_RTSP_USERNAME and HC_TV_RTSP_PASSWORD, and drives PTZ through /api/v1/tv/ptz/{camera}/move and /stop. Revoking a TV deletes its token.

The wall follows the web wall's automatic landscape layout, filled by column with the lenses of a camera stacked in one column; a tile's index is its slot in that grid. tv_wall composes every enabled camera into one 1920x1080 H.264 stream at 15 fps and 6 Mbit/s from the sub streams where they exist, and tv_tile_<n> is one lens at 1920x1080 and 4 Mbit/s from the main stream. Both are exec sources in go2rtc.yaml, because go2rtc refuses exec sources through its API: go2rtc runs go2rtc-tv.sh only while a TV watches, the script fetches the current ffmpeg arguments from the backend at /internal/tv/streams/<name>, and ffmpeg reads the camera streams back from go2rtc on loopback, decodes on the CPU, crops and scales the lenses, overlays them on a dark 1920x1080 canvas and encodes with h264_nvenc for ultra low latency. tv_tile_0 to tv_tile_15 exist, so a wall with more than 16 slots offers only the first 16 fullscreen.

An offline camera never holds up the picture. Before each start the backend leaves out cameras whose status probe fails, whose go2rtc stream carries no data or does not open, and cameras in a cooldown; their cells show Offline on the canvas. ffmpeg ends an input that sends nothing for 2 s, so a camera that stops mid-stream freezes the picture for a few seconds and then shows Offline while the rest plays on. The script reports inputs ffmpeg cannot open and asks the backend for the arguments every 5 s; the backend notices inputs that dropped out of a running stream, puts their cameras in a cooldown of 1 minute doubling up to 10, and when the arguments change, because of a layout change, a camera going offline or one coming back, the script restarts ffmpeg and go2rtc carries the playing TV over to the new picture. Decoding starts at the camera's current frame, so a cell can show grey until that camera's next keyframe, up to 4 s.

## Security

- Every page, API call and video connection needs a session; nginx checks the session before it proxies the video websocket and snapshots.
- Camera passwords are stored encrypted with a key derived from HC_SECRET_KEY and are never returned by the API. Changing HC_SECRET_KEY makes stored camera passwords unreadable, so re-enter them afterwards.
- Every go2rtc path other than the video websocket, snapshots and the player module returns 404 through nginx.
- go2rtc asks RTSP clients for HC_TV_RTSP_USERNAME and HC_TV_RTSP_PASSWORD except on loopback, so the TV needs them and go2rtc's own ffmpeg sources do not. The TV pairing and status calls need no session, the config and PTZ calls need a paired TV's token, and /internal is served by the backend only, never through nginx. Revoking a TV removes its API access, but every TV shares the RTSP credentials, so change HC_TV_RTSP_PASSWORD to lock out a lost TV.
- The bridges serve RTSP and ONVIF without authentication, so they stay on the internal network and never publish ports.

## OpenCV viewer

cv/ holds a separate desktop viewer that opens the EZVIZ streams with OpenCV; it reads CAMERA_PASSWORD from .env.
