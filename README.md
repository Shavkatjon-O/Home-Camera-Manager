# Home cameras

A web app for the home IP cameras: register cameras, watch one camera large, watch all of them at once as a security wall, find cameras on the network and drive PTZ cameras.

## Services

| Service | Image | Role |
|---|---|---|
| postgres | postgres:17.6-alpine | Users and the camera registry |
| go2rtc | alexxit/go2rtc:1.9.14 | Pulls each camera's RTSP stream and serves it to the browser, transcoding to H.264 when needed |
| backend | home-cameras-backend:local | FastAPI: sign in, cameras, discovery, ONVIF PTZ, go2rtc stream registration and status probes |
| web | home-cameras-web:local | nginx serving the Next.js static export and proxying the API and the video websocket |

Only the web service publishes a port, 8750, on loopback and on the home network address in HC_LAN_BIND, so phones on the home Wi-Fi reach it while the VPN does not.

## Run

```
cp .env.example .env
docker compose up -d --build
```

Set HC_SECRET_KEY to a long random value and HC_LAN_BIND to this machine's home network address before the first start; reserve that address in the router so it does not change. Open http://127.0.0.1:8750 and sign in with HC_ADMIN_USERNAME and HC_ADMIN_PASSWORD; the backend creates that user on first start and never overwrites its password afterwards.

## Pages

- **Wall** - every enabled camera in one grid that fills the screen, sub streams, automatic or forced 1, 2x2 and 3x3 layouts, fullscreen for the wall and for each tile.
- **Camera** - one camera on its main or sub stream, its details and status, and a PTZ pad with speed for PTZ cameras; arrow keys and plus or minus drive it while the view has focus.
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

EZVIZ cameras need Local Service Settings switched on in the EZVIZ app; their user is admin and their password is the camera's image-encryption password. V380 cameras need RTSP and ONVIF open on ports 554 and 8899.

## Streaming

The backend registers two go2rtc streams per enabled camera, main and sub, each with the camera's RTSP URL followed by an ffmpeg H.264 transcode, and reconciles go2rtc with the registry on every monitor tick. The browser player asks for H.264 only, so H.265 cameras always play through the transcode. go2rtc.yaml holds no streams and is mounted read-only, so camera credentials stay out of files.

## Security

- Every page, API call and video connection needs a session; nginx checks the session before it proxies the video websocket and snapshots.
- Camera passwords are stored encrypted with a key derived from HC_SECRET_KEY and are never returned by the API. Changing HC_SECRET_KEY makes stored camera passwords unreadable, so re-enter them afterwards.
- Every go2rtc path other than the video websocket, snapshots and the player module returns 404 through nginx.

## OpenCV viewer

cv/ holds a separate desktop viewer that opens the EZVIZ streams with OpenCV; it reads CAMERA_PASSWORD from .env.
