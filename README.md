# Home cameras

A web app for the home IP cameras: register cameras, watch one camera large, watch all of them at once as a security wall, find cameras on the network and drive PTZ cameras.

## Services

| Service | Image | Role |
|---|---|---|
| postgres | postgres:17.6-alpine | Users and the camera registry |
| go2rtc | alexxit/go2rtc:1.9.14-hardware | Pulls each camera's RTSP stream and serves it to the browser, encoding H.264 on the NVIDIA GPU when needed |
| backend | home-cameras-backend:local | FastAPI: sign in, cameras, discovery, ONVIF PTZ, go2rtc stream registration and status probes |
| v380-ptz-1, v380-ptz-2 | home-cameras-v380-bridge:local | One bridge per V380 camera: logs in over the V380 protocol on port 8800, decrypts the stream and serves it as RTSP on 8554 and ONVIF with PTZ on 8080 |
| web | home-cameras-web:local | nginx serving the Next.js static export and proxying the API and the video websocket |

The host needs an NVIDIA GPU with the NVIDIA container toolkit. Only the web service publishes a port, 8750, on loopback and on the home network address in HC_LAN_BIND, so phones on the home Wi-Fi reach it while the VPN does not.

## Run

```
cp .env.example .env
docker compose up -d --build
```

Set HC_SECRET_KEY to a long random value and HC_LAN_BIND to this machine's home network address before the first start; reserve that address in the router so it does not change. Open http://127.0.0.1:8750 and sign in with HC_ADMIN_USERNAME and HC_ADMIN_PASSWORD; the backend creates that user on first start and never overwrites its password afterwards.

## Pages

- **Wall** - every enabled camera in one grid that fills the screen, sub streams, automatic or forced 1, 2x2 and 3x3 layouts, fullscreen for the wall and for each tile. A camera with several lenses takes one tile per lens.
- **Camera** - one camera on its main or sub stream, its details and status, and a PTZ pad with speed for PTZ cameras; arrow keys and plus or minus drive it while the view has focus. A camera with several lenses shows them side by side or one at a time.
- **Cameras** - the registry: add, edit, delete and the wall order. Detect reads stream paths and PTZ support from the camera over ONVIF.
- **Discover** - scans the home subnet for cameras and opens the add form prefilled for any it finds.

## Cameras

The brand fills the defaults for fields left empty:

| Brand | ONVIF port | Main path | Sub path | PTZ |
|---|---|---|---|---|
| ezviz | 80 | /Streaming/Channels/101 | /Streaming/Channels/102 | no |
| v380 | 8899 | /live/ch00_0 | /live/ch00_1 | yes |
| onvif | given | from ONVIF GetStreamUri | from ONVIF GetStreamUri | from the profile |
| rtsp | none | required | optional | no |

EZVIZ cameras need Local Service Settings switched on in the EZVIZ app; their user is admin and their password is the camera's image-encryption password.

V380 cameras go through their bridge, because their own RTSP server stops answering once a device password is set and some models have no RTSP or ONVIF at all. A bridge needs the camera's address and device ID in V380_PTZ_<n>_HOST and V380_PTZ_<n>_ID, and the shared V380_USERNAME and V380_PASSWORD set as the device login in V380 Pro. Register the camera with brand onvif, host home-cameras-v380-ptz-<n>, RTSP port 8554, ONVIF port 8080, main path /live, no sub path, no login and PTZ on. Another V380 camera gets another bridge service and env group in the same shape. Dual-lens cameras send both pictures stacked in one frame; set Lenses to 2 and the browser crops each band into its own view, with no extra transcoding. Discover lists V380 cameras by their port 8800 even when RTSP is closed.

## Streaming

The backend registers two go2rtc streams per enabled camera, main and sub, each with the camera's RTSP URL followed by an ffmpeg H.264 video transcode without audio, and reconciles go2rtc with the registry on every monitor tick. The browser player asks for H.264 only, so H.265 cameras always play through the transcode. go2rtc.yaml holds no streams and is mounted read-only, so camera credentials stay out of files; its ffmpeg h264 template encodes with h264_nvenc while decoding on the CPU. HC_TRANSCODE_HARDWARE adds a go2rtc hardware option such as cuda to every transcode for GPU decoding as well; it stays empty because GPU decoding fails on some bridge streams.

## Security

- Every page, API call and video connection needs a session; nginx checks the session before it proxies the video websocket and snapshots.
- Camera passwords are stored encrypted with a key derived from HC_SECRET_KEY and are never returned by the API. Changing HC_SECRET_KEY makes stored camera passwords unreadable, so re-enter them afterwards.
- Every go2rtc path other than the video websocket, snapshots and the player module returns 404 through nginx.
- The bridges serve RTSP and ONVIF without authentication, so they stay on the internal network and never publish ports.

## OpenCV viewer

cv/ holds a separate desktop viewer that opens the EZVIZ streams with OpenCV; it reads CAMERA_PASSWORD from .env.
