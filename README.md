# Home cameras

A web app for the home IP cameras: register cameras, watch one camera large, watch all of them at once as a security wall, find cameras on the network and drive PTZ cameras. An Android TV app in tv/ shows the cameras on the living-room TV on its own, straight from the cameras, as tv/README.md describes.

## Services

| Service                | Image                          | Role                                                                                                                                                     |
| ---------------------- | ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| postgres               | postgres:17.6-alpine           | Users, the camera registry, the floor plans, the network devices and the health samples and outages                                                      |
| go2rtc                 | alexxit/go2rtc:1.9.14-hardware | Pulls each camera's RTSP stream and serves it to the browser, encoding H.264 on the NVIDIA GPU when needed, and serves the composed TV streams over RTSP |
| backend                | home-cameras-backend:local     | FastAPI: sign in, cameras, discovery, ONVIF PTZ and camera settings, camera events, floor plans, TV pairing, go2rtc streams, status and health probes |
| analytics              | home-cameras-analytics:local   | DeepStream 9.1: detects, tracks and applies zones, lines and rules on every enabled analytics view, recognises faces, records the rolling buffer and cuts event clips |
| v380-ptz-1, v380-ptz-2 | home-cameras-v380-bridge:local | One bridge per V380 camera: logs in over the V380 protocol on port 8800, decrypts the stream and serves RTSP on 8554 and ONVIF with PTZ, light and siren on 8080 |
| web                    | home-cameras-web:local         | nginx serving the Next.js static export and proxying the API and the video websocket                                                                     |

The host needs an NVIDIA GPU with the NVIDIA container toolkit. The web service publishes 8750 on loopback and on the home network address in HC_LAN_BIND, and go2rtc publishes its RTSP port 8554 on HC_LAN_BIND only, so phones and the TV on the home Wi-Fi reach them while the VPN does not.

## Run

```
cp .env.example .env
scripts/download-models.sh
docker compose up -d --build
```

Set HC_SECRET_KEY to a long random value, HC_TV_RTSP_PASSWORD and HC_ANALYTICS_TOKEN to two others, HC_TIMEZONE to the zone the schedules use, and HC_LAN_BIND to this machine's home network address before the first start; reserve that address in the router so it does not change. Open http://127.0.0.1:8750 and sign in with HC_ADMIN_USERNAME and HC_ADMIN_PASSWORD; the backend creates that user on first start and never overwrites its password afterwards.

## Pages

- **Wall** - every enabled camera in one grid that fills the screen, sub streams, automatic or forced 1, 2x2 and 3x3 layouts, fullscreen for the wall and for each tile. A camera with several lenses takes one tile per lens.
- **Camera** - one camera on its main or sub stream with an optional sound toggle, its details and status, and a PTZ pad with speed for PTZ cameras; arrow keys and plus or minus drive it while the view has focus. A camera with several lenses shows them side by side or one at a time. The sidebar holds what the camera itself offers, each section read from the camera and labelled when it is not offered: presets and home position, light and siren on V380 cameras, its recent events, the SD card recordings of a day, video encoders, image settings, motion detection and the device with its clock, time sync and reboot.
- **Camera, analytics** - one row per analytics view, the whole camera or each lens of a multi-lens camera: enable, profile, moving lens, live frame rate, objects, zone occupancy and line counts, and the zone and line editor, which draws on a fresh picture of the view. Each view also switches re-identification, falls, number plates and, on a moving lens, auto-follow, and each zone sets objects left and taken and what animals do there. A toggle in the top bar draws the tracked boxes over the live video.
- **Cameras** - the registry: add, edit, delete and the wall order. Detect reads stream paths and PTZ support from the camera over ONVIF.
- **Events** - what the cameras report themselves, live: newest first with a thumbnail, camera, kind, start and duration or Ongoing, filters for camera, kind and day, and a chip per camera saying whether its event channel is live. An event opens a side panel with the snapshot, the times, the camera's own time and the message it sent. The wall marks a tile with Motion while an event is open on its camera, and every page announces new alert events unless they are muted in the top bar. Analytics events add kinds and object labels to the filters, counts for the filtered events, the boxes of the objects over the snapshot and the event clip. Face events name the person or the unknown cluster with the face crop, and the wall shows a recognised person's name on the tile for 8 s. A vehicle event shows its number plate candidates, a person event the journey that person took across the cameras and Find this person on other cameras, and a Plate filter finds vehicle events by plate.
- **People** - known people with their sample faces and latest sightings, enrollment from photos that must each show exactly one face, and unknown faces grouped into clusters such as Unknown 3, seen 5 times, which Who is this? turns into a new or existing person, relabelling the cluster's past events. People and clusters can be merged and deleted, and deleting wipes their faces and crops. Faces never leave this computer.
- **Counts** - line crossings in and out per line by hour for a day and by day for two weeks, with a label filter, and the occupancy of areas bounded by lines, such as the house behind the entrance door, with a daily reset time and a way to set the count by hand.
- **Search** - every event filtered by time, cameras, views, kinds, labels, zones, lines, person or cluster and alerts, as a list or a grid, and Find similar on any face or on an uploaded photo, ranked by similarity.
- **Discover** - scans the home subnet for cameras and opens the add form prefilled for any it finds; a camera counts as added when its address matches a camera's host or device address.
- **Coverage** - plans Wi-Fi coverage on a floor plan: routers, optional walls by material, devices and an optional background image whose shape sets the plan height. A heatmap shows the predicted signal per band with distance and wall loss, the side panel gives the covered share and what each router serves, and Suggest placement moves unlocked routers to the spots that cover the most area. Where no walls are drawn the model assumes open space.
- **Health** - how stable each router and camera is over the last hour, 24 hours or 7 days: a card per target with its status, uptime, typical and p95 latency, outage count, an availability strip and a latency line, and an outage log below. A card opens a side panel with a finer latency chart, the target's outages with the device that caused them, and editing of the device or of how the camera connects.

## Health

The backend probes every enabled network device and camera every HC_HEALTH_INTERVAL_SECONDS with a TCP connect that gives up after 1.5 s, and stores one sample per target with its latency or error. A device is probed on its address and probe port; a camera on its RTSP host and port, or on its device address and the V380 port 8800 when it streams through a bridge, because the bridge container answers even when the camera is gone. Samples older than HC_HEALTH_RETENTION_DAYS are deleted every hour.

Each network device and each camera link names the device it connects through and how: cable, Wi-Fi 2.4 GHz or Wi-Fi 5 GHz. Two failed samples in a row open an outage that starts at the first of them, and the first answer closes it. When the upstream device of a target is down at the start of the target's outage, or goes down within two probe intervals after it, the outage counts as caused upstream and names the top device of that chain, so a camera behind a repeater that dropped with the main router names the main router.

Uptime is the share of answered samples in the range; latency figures cover answered samples only. The 1 hour range shows 1 minute bars, 24 hours 15 minute bars and 7 days 2 hour bars, and the side panel's chart uses 30 second, 5 minute and 30 minute bars. Bars are green when every sample answered, amber when some did, red when none did and grey without samples.

## Cameras

The brand fills the defaults for fields left empty:

| Brand | ONVIF port | Main path               | Sub path                | PTZ              |
| ----- | ---------- | ----------------------- | ----------------------- | ---------------- |
| ezviz | 80         | /Streaming/Channels/101 | /Streaming/Channels/102 | no               |
| v380  | 8899       | /live/ch00_0            | /live/ch00_1            | yes              |
| onvif | given      | from ONVIF GetStreamUri | from ONVIF GetStreamUri | from the profile |
| rtsp  | none       | required                | optional                | no               |

EZVIZ cameras need Local Service Settings switched on in the EZVIZ app; their user is admin and their password is the camera's image-encryption password.

V380 cameras go through their bridge, because their own RTSP server stops answering once a device password is set and some models have no RTSP or ONVIF at all. A bridge needs the camera's address and device ID in V380_PTZ_<n></n>_HOST and V380_PTZ_<n></n>_ID, and the shared V380_USERNAME and V380_PASSWORD set as the device login in V380 Pro. Register the camera with brand onvif, host home-cameras-v380-ptz-<n></n>, device address the camera's own LAN address, RTSP port 8554, ONVIF port 8080, main path /live, no sub path, no login and PTZ on. Another V380 camera gets another bridge service and env group in the same shape. Dual-lens cameras send both pictures stacked in one frame; set Lenses to 2 and the browser crops each band into its own view, with no extra transcoding. Discover lists V380 cameras by their port 8800 even when RTSP is closed.

## Events

The backend keeps one ONVIF PullPoint subscription per enabled camera: it reads the camera's event topics, long-polls PullMessages, renews before the subscription expires, reconnects with backoff and unsubscribes on shutdown. A bridged camera is subscribed on its own device address and HC_DEVICE_ONVIF_PORT with V380_USERNAME and V380_PASSWORD, because the bridge has no events. A camera that answers on its stream port but has no ONVIF service is shown as not supported and retried every 10 minutes. When a camera refuses PullMessages the subscriber falls back to polling: it subscribes every 5 s and reads the states the camera reports at subscription.

Motion topics become motion events, person and vehicle when the message carries such a class, image and video loss topics tamper events, storage failures storage events and a new LastReboot time a reboot event. Start and stop messages within 5 s merge into one event, all topics of one kind on a camera share the open event, and an open event closes after 10 minutes. Event times use this computer's clock and keep the camera's own time beside it. States a camera reports when a subscription starts never open an event, because they started at an unknown time; too dark, too bright and blurry states are shown as conditions of the camera. On start the backend saves a snapshot and a 320 px thumbnail from go2rtc's frame of the sub stream, or the main stream when there is none, to the events volume. Events older than HC_EVENTS_RETENTION_DAYS are deleted with their images every hour.

GET /api/v1/events lists events with filters and paging, /api/v1/events/sources the state of each camera's event channel, and /api/v1/events/stream pushes new and changed events and source changes as server-sent events; nginx serves the stream without buffering.

## Camera settings

The camera view reads and writes the camera over ONVIF: device information and clock, Media2 video encoders with their options (Media when there is no Media2), imaging settings with their options, the cell motion detector's sensitivity and active cells, PTZ presets and the home position, and the SD card's recording summary and per-day timeline from the search service. A bridged camera uses its own device ONVIF for all of this, and the bridge's presets only where the bridge keeps any. Sync time sets the camera's UTC time and puts a camera that was on NTP back on NTP. The light and siren of V380 cameras go through the bridge's API on the internal network. Playback of SD card recordings stays off with HC_REPLAY_ENABLED=false, because the cameras reset local playback sessions right after PLAY and go2rtc keeps redialling a failed source after its stream is removed; when it is on, one session per camera plays through a temporary go2rtc stream that is removed on the first failure or when nobody watches.

## Streaming

The backend registers two go2rtc streams per enabled camera, main and sub, each with the camera's RTSP URL followed by an ffmpeg H.264 video transcode without audio, and reconciles go2rtc with the registry on every monitor tick. The browser player asks for H.264 only, so H.265 cameras always play through the transcode. With sound on, the camera view also asks for audio, which go2rtc takes from the camera's own RTSP source, so an EZVIZ camera plays its AAC sound without an audio transcode; bridged cameras carry no sound. go2rtc.yaml holds no camera streams and is mounted read-only, so camera credentials stay out of files; its ffmpeg h264 template encodes with h264_nvenc while decoding on the CPU. HC_TRANSCODE_HARDWARE adds a go2rtc hardware option such as cuda to every transcode for GPU decoding as well; it stays empty because GPU decoding fails on some bridge streams.

## TV

The backend serves a composed wall and tiles to paired TV clients; the Android TV app in tv/ does not use this path and connects to the cameras itself. A TV client pairs once: it asks POST /api/v1/tv/pairings for a 6-digit code, the code is approved through POST /api/v1/tv/pairings/approve, which the web UI no longer offers since the TV app runs on its own, and the next poll of GET /api/v1/tv/pairings/{id} hands the TV its device token once. Codes expire after 10 minutes, at most 5 wait at once and each address may ask for 10 a minute. With the token as a Bearer header the TV reads GET /api/v1/tv/config, which lists the wall and every tile with RTSP URLs on HC_LAN_BIND carrying HC_TV_RTSP_USERNAME and HC_TV_RTSP_PASSWORD, and drives PTZ through /api/v1/tv/ptz/{camera}/move and /stop. Revoking a TV deletes its token.

The wall follows the web wall's automatic landscape layout, filled by column with the lenses of a camera stacked in one column; a tile's index is its slot in that grid. tv_wall composes every enabled camera into one 1920x1080 H.264 stream at 15 fps and 6 Mbit/s from the sub streams where they exist, and tv_tile_<n></n> is one lens at 1920x1080 and 4 Mbit/s from the main stream. Both are exec sources in go2rtc.yaml, because go2rtc refuses exec sources through its API: go2rtc runs go2rtc-tv.sh only while a TV watches, the script fetches the current ffmpeg arguments from the backend at /internal/tv/streams/<name></name>, and ffmpeg reads the camera streams back from go2rtc on loopback, decodes on the CPU, crops and scales the lenses, overlays them on a dark 1920x1080 canvas and encodes with h264_nvenc for ultra low latency. tv_tile_0 to tv_tile_15 exist, so a wall with more than 16 slots offers only the first 16 fullscreen.

An offline camera never holds up the picture. Before each start the backend leaves out cameras whose status probe fails, whose go2rtc stream carries no data or does not open, and cameras in a cooldown; their cells show Offline on the canvas. ffmpeg ends an input that sends nothing for 2 s, so a camera that stops mid-stream freezes the picture for a few seconds and then shows Offline while the rest plays on. The script reports inputs ffmpeg cannot open and asks the backend for the arguments every 5 s; the backend notices inputs that dropped out of a running stream, puts their cameras in a cooldown of 1 minute doubling up to 10, and when the arguments change, because of a layout change, a camera going offline or one coming back, the script restarts ffmpeg and go2rtc carries the playing TV over to the new picture. Decoding starts at the camera's current frame, so a cell can show grey until that camera's next keyframe, up to 4 s.

## Analytics

The analytics service in analytics/ runs on NVIDIA DeepStream 9.1, the newest DeepStream image on nvcr.io, with CUDA 13.2 and TensorRT 10.16. It reads every enabled camera's original stream from go2rtc, decodes it once on the GPU, cuts multi-lens frames into one view per lens and runs one shared detector, RF-DETR Medium, and the NvDCF tracker on all views at 8 frames per second by default. A rules engine in plain Python turns tracked people, vehicles and animals into intrusion, vehicle, animal, loitering, crowd and line crossing events, and a tamper guard reports covered, blurred, too dark or moved views. analytics/README.md describes the pipeline and the rules.

Its configuration lives in the backend: views per camera and lens with a profile, zones and lines with class filters, dwell, loitering, crowd counts, schedules and alert policies, and the global arm mode in the top bar. The service reads it from /internal/analytics/config every 5 s, so zone changes apply without a restart, and posts events and per view observations back. Disarmed never alerts, Home alerts for zones and lines whose alert is Always, Schedule adds those whose alert windows are active, and Away alerts for every analytics event. Camera events alert for tamper, storage and reboot. Alerts raise a toast and count on the Events tab.

Zones on a moving lens keep the picture they were drawn on. When the lens points elsewhere the view no longer matches that picture, its zones and lines are suspended and the camera page says so; whole-view zones keep working wherever the lens points.

Every event gets a snapshot of its view and a clip from 5 s before it starts to 5 s after it ends, at most 60 s. The service keeps two minutes of each camera's original stream as copied segments in memory and encodes the clip once to H.264 MP4, on NVENC or with libx264 where no hardware encoder exists, so clips play in every browser. Clips and snapshots sit in the events volume and are deleted with their events.

Faces are recognised on the indoor views by default and on any view where they are turned on. SCRFD finds faces on the tracked people, the best few faces of each person track are aligned and embedded with glintr100, and the track is named when it matches an enrolled person clearly enough; other faces gather into unknown clusters to name later. Each person or cluster makes at most one event per view in 10 minutes, attached to the analytics event of the same person. People, clusters and face samples live in the backend, which enrolls photos through the analytics service because only it has the GPU models; event face samples follow the event retention, while enrolled ones stay until deleted. analytics/README.md gives the thresholds and how they were measured.

The tamper guard checks every view about every 5 s against what the view normally shows, with one learned reference for day and one for infrared night and a grace after each switch, so the switch at dusk raises nothing. A blank wall, as PTZ 1 Lens 1 sees, has too little structure to tell blur or movement, so only covering and darkness are reported there. A moving lens is never reported moved: when it turns, by hand or by the camera's own tracking, its reference starts again from the new picture.

Every line counts crossings in and out by label and minute; the Counts page sums them by hour and day, and an area's occupancy is the crossings into it minus those out of it since its daily reset or since it was set by hand. A zone can also watch for objects left and taken: a backpack, handbag, suitcase, bicycle or motorcycle, or a car or other label the zone lists, that arrives and stays still for the zone's time raises object left, and an object present for the zone's time that goes away while someone is near raises object taken. Objects already there when the service starts never count as left, so parked cars and boxes stay silent. A zone can add a background comparison that also finds objects the detector has no class for. Dogs, cats and birds open animal events instead of intrusions, and a zone or line records them without alerts unless it includes them, in every arm mode, so a cat in the yard at night does not wake anyone.

Falls (beta) are watched on the views where they are turned on: RTMPose finds the body keypoints of each tracked person on a crop of the person widened by a quarter, and a fast change from upright to lying followed by lying still for 8 s raises a fall event, while lying down slowly or bending does not. Number plates (beta) are read on vehicle events of the views where they are turned on: the service cuts the vehicle out of the recording buffer at full resolution a few times during the event, finds the plate with PaddleOCR's DB text detector and reads it with the PaddleOCR recogniser, fits the text to the Uzbek plate formats and votes over the reads; the candidates go with the event and the Plate filter finds them. At night the infrared light glares on the plates, so grey pictures are not read and the event says so instead.

Re-identification gives each person track an appearance vector from OSNet-AIN, averaged over its crops. When a track ends it is linked to the most similar track of another view that ended shortly before, if each is the other's best match after centring on the mean of all tracks, into a journey such as Yard, then Entrance, then Corridor; Find this person ranks the tracks of every camera in the week around an event by the same similarity. Appearance in daylight and under infrared differ too much to compare, so links and matches hold within day or within night.

Auto-follow on a moving lens keeps one person centred with a small dead zone and a speed limit, stops when the person is lost and returns the lens to where it was 30 s after the last person by retracing its moves, one reverse command for each move. PTZ 1 gets its moves on its own ONVIF device and PTZ 2 through the bridge. A preset return can be turned on per view, but PTZ 1 answers GotoPreset without moving, and each of its moves turns the lens a fixed step of about a tenth of the picture whatever the speed and duration. It is off on every view: the cameras turn by themselves only on the views where it is turned on.

Model weights stay outside the repository. scripts/download-models.sh downloads them into HC_ANALYTICS_MODELS_DIR with pinned checksums, exports the detector to ONNX and prints each licence, and scripts/download-face-models.sh fetches the InsightFace face models, published for non-commercial research use only, into HC_ANALYTICS_FACE_MODELS_DIR. scripts/download-secondary-models.sh fetches OSNet-AIN (MIT), RTMPose-m (Apache 2.0) and the PaddleOCR text detector and recogniser (Apache 2.0) into HC_ANALYTICS_MODELS_DIR, and with --all also NVIDIA LPDNet, an optional plate finder whose model card states commercial use under the NVIDIA AI Enterprise EULA rather than an open licence, selected with HC_ANALYTICS_PLATE_FINDER=lpdnet. The TensorRT engines are built on first start into the analytics-engines volume.

## Jetson Orin Nano

compose.jetson.yml runs the stack on a Jetson Orin Nano with DeepStream 9.1 or later on JetPack 7.2, which has no hardware video encoder:

```
docker compose -f compose.yml -f compose.jetson.yml up -d --build
```

The analytics service uses RF-DETR Nano at 4 frames per second with a batch of six, encodes clips with libx264, keeps one minute of buffer in 512 MB, reads no number plates and is limited to 3 GB; go2rtc runs from the plain multi-architecture image with a libx264 transcode template and no GPU reservation. Verified on the PC: the merged configuration, that the DeepStream 9.1 image carries an arm64 variant with CUDA 13.2, and the libx264 clip path, which turned 10 s of 2880x1620 H.265 into a 1080p H.264 clip in 1.9 s and 6.9 CPU seconds on four cores. Not verified: the stack has not run on a Jetson, so the arm64 build of the analytics image and its parser library, RF-DETR Nano's speed there, the CPU cost of go2rtc's browser transcodes of four 5 MP streams and the composed TV streams, which still encode with h264_nvenc, are open. Export the detector ONNX on a PC with scripts/download-models.sh --all and copy the model folder over.

## Security

- Every page, API call and video connection needs a session; nginx checks the session before it proxies the video websocket and snapshots.
- Camera passwords are stored encrypted with a key derived from HC_SECRET_KEY and are never returned by the API. Changing HC_SECRET_KEY makes stored camera passwords unreadable, so re-enter them afterwards.
- Every go2rtc path other than the video websocket, snapshots and the player module returns 404 through nginx.
- go2rtc asks RTSP clients for HC_TV_RTSP_USERNAME and HC_TV_RTSP_PASSWORD except on loopback, so the TV needs them and go2rtc's own ffmpeg sources do not. The TV pairing and status calls need no session, the config and PTZ calls need a paired TV's token, and /internal is served by the backend only, never through nginx. Revoking a TV removes its API access, but every TV shares the RTSP credentials, so change HC_TV_RTSP_PASSWORD to lock out a lost TV.
- The analytics service publishes no port. /internal/analytics on the backend needs HC_ANALYTICS_TOKEN as a bearer token, the service's own status endpoint asks for the same token, and nginx answers 404 for every /internal path.
- The bridges serve RTSP and ONVIF without authentication, so they stay on the internal network and never publish ports.

## OpenCV viewer

cv/ holds a separate desktop viewer that opens the EZVIZ streams with OpenCV; it reads CAMERA_PASSWORD from .env.
