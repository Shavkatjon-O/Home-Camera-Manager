# Analytics

Video analytics for the home cameras on NVIDIA DeepStream 9.1 (the newest DeepStream image on nvcr.io, with CUDA
13.2 and TensorRT 10.16): people, vehicle and animal detection, tracking, zones,
lines, loitering, crowding and tamper watch, with an event clip and snapshot for every event.

## How it works

- The service reads each camera's original H.265 stream from go2rtc's RTSP server and decodes it once on NVDEC.
- A multi-lens camera sends its lenses stacked in one frame. A tee and one cropping nvvideoconvert per lens turn every
  lens into its own source in the batch, so the tracker never mixes objects across lenses and each lens has its own
  zones.
- Each view drops frames to its analysis rate (8 fps by default) and ends in a leaky queue, and nvurisrcbin
  reconnects a lost stream by itself, so one dead camera never holds up the others.
- The batch runs through one shared detector, RF-DETR Medium at 1024x576 with a custom bounding box parser, and the
  NvDCF tracker. A probe after the tracker hands every frame's tracked objects to the service.
- The pipeline runs in a child process. A crash in native code takes down only the pipeline, which the service
  restarts, and a configuration change restarts it only when the decoded or analysed views change.
- The rules engine in app/rules is plain Python with no DeepStream import, so it runs on any host that produces
  tracked boxes and is tested without a GPU. Zone and rule changes apply without touching the pipeline.
- One ffmpeg process per camera copies the stream into two-second segments without re-encoding and decodes only the
  keyframes into small grey pictures for the tamper watch. An event's snapshot and clip are cut from these segments:
  the clip starts a few seconds before the event, is cropped to the event's lens and is encoded once to H.264 MP4 with
  NVENC, or with libx264 where no hardware encoder exists, such as a Jetson Orin Nano.

## Profiles

| Profile | Stages |
|---|---|
| perimeter | detector, tracker, zones, lines and rules for people, animals and vehicles, tamper watch |
| vehicle | detector, tracker, zones, lines and rules for vehicles, tamper watch |
| identity | detector, tracker and rules for people, and the face stage |
| tamper | tamper watch only, without the detector |

## Rules

- A zone is a polygon with a class filter, a minimum dwell, an optional loitering time, an optional crowd count, a
  schedule and an alert policy. An object is inside when its foot point, the bottom centre of its box, is.
- An intrusion opens when an object has stayed inside for the dwell and closes once nothing qualifying has been inside
  for the close delay; each zone keeps one event per label, and vehicles open vehicle events.
- Vehicles, and anything already in the picture when a view starts, count only after they move, and objects that stay
  in place for minutes become part of the scene, so parked cars and standing false detections stay silent.
- A line counts crossings in both directions. Crossing from the negative to the positive side is in; for a line drawn
  from left to right that means moving down the picture. An object must clear the line by a margin on both sides and
  its path must cut the drawn segment.
- Loitering and line crossings are instant events, debounced per object. A track the tracker loses and finds again
  near the same place within a few seconds stays the same object.
- Arm modes: disarmed never alerts, home alerts for policies that always alert, schedule adds the policies whose alert
  windows are active, and away alerts for every event.

## Faces

Face recognition runs on every view whose profile is identity and on any view that turns faces on.

- SCRFD 10G runs as a secondary nvinfer on the tracked person boxes of those views, at 640 by 640 with the person
  scaled in without distortion, and attaches its raw outputs to each person. Running it on person boxes instead of
  whole frames costs nothing on empty frames, gives a face far more detector pixels than a 1080p frame scaled to
  640, and hands every face its person's track id.
- A probe after the face detector takes the face in the upper part of each person box, judges it by size, landmark
  frontality, sharpness and score, and only when it beats what the track already sent copies the region around it
  out of the frame, aligns it to the 112 by 112 template with a similarity transform from its five landmarks and
  sends it to the service. A track sends its first usable face at once, a clearly better one at any time, a
  comparable one every 2 seconds and at most 12 in all.
- The service keeps the 5 best faces of each track, embeds them with glintr100 through TensorRT and decides the
  track after 3 faces or 3 seconds from the quality-weighted mean of their embeddings. A track that ends as unknown
  is checked again with all its faces and named when they match.
- A known face needs a similarity of 0.45 to one of the person's samples, 0.50 when the face is grey from night
  vision, and a lead of 0.08 over the next person. Everything else is unknown, joins the closest unknown cluster at
  0.45 or starts a new one, and records the closest person from 0.30. A track whose faces average below 0.35 in
  quality never starts a cluster. The same person or cluster makes at most one event per view within the cooldown.
- The thresholds come from the 6000 pairs of a public face verification benchmark, each face also shrunk to a 40
  pixel door-camera face and turned grey: different people never scored above 0.27, and the same person scored
  0.63 to 0.71 in the median, so 0.45 keeps a wide gap to strangers and lookalike relatives while accepting about 98
  percent of small daylight faces and 92 percent of small grey faces against an enrolled photo.
- Face events, crops and the gallery of known people and unknown clusters live in the backend. The service polls
  the gallery, posts one face result per decided track and writes the 160 pixel crop under faces/ in the events
  folder. POST /identity/embed with a photo as the body answers its faces with boxes, landmarks, quality and
  embedding, which the backend uses to enroll people.
- The two engines take about 270 MB of GPU memory, and embedding a face takes 1 to 2.5 ms.

The models are the InsightFace antelopev2 pack, which the InsightFace model zoo publishes for non-commercial research
use only; scripts/download-face-models.sh fetches and checks them.

## Run

The service runs as the analytics service of the repository's compose.yml, which reads its views, zones and lines
from the backend. Download the models first:

```
scripts/download-models.sh
scripts/download-face-models.sh
docker compose up -d --build analytics
```

Without HC_ANALYTICS_BACKEND_URL the service reads the same configuration from the JSON file in
HC_ANALYTICS_CONFIG_FILE instead, for a host without the backend. The first start builds the TensorRT engine into
the engine volume, which takes about a minute.

## Configuration

| Name | Default | Meaning |
|---|---|---|
| HC_ANALYTICS_MODELS_DIR | analytics/models | Model folder mounted read-only at /models |
| HC_ANALYTICS_FACE_MODELS_DIR | analytics/models/face | Face model folder mounted read-only at /face-models |
| HC_ANALYTICS_DETECTOR | rfdetr-medium | Shared detector |
| HC_ANALYTICS_FPS | 8 | Analysis rate of views that set none |
| HC_ANALYTICS_CLIP_ENCODER | auto | auto, h264_nvenc, libx264 or copy |
| HC_ANALYTICS_CLIP_BEFORE | 5 | Seconds a clip starts before its event |
| HC_ANALYTICS_CLIP_AFTER | 5 | Seconds a clip runs after its event |
| HC_ANALYTICS_CLIP_MAX | 60 | Longest clip in seconds |
| HC_ANALYTICS_BUFFER_SECONDS | 120 | Seconds of segments kept per camera |
| HC_TIMEZONE | UTC | Time zone of schedules |
| HC_ANALYTICS_BACKEND_URL | empty | Backend the configuration comes from and events go to |
| HC_ANALYTICS_TOKEN | empty | Shared token of the backend's internal routes and the status endpoint |
| HC_FACES_COOLDOWN_SECONDS | 600 | Seconds during which a person or cluster makes one event per view |
| HC_FACES_KNOWN_THRESHOLD | 0.45 | Similarity that names a person |
| HC_FACES_IR_EXTRA | 0.05 | Added to the known threshold for grey faces |
| HC_FACES_MARGIN | 0.08 | Lead over the next person needed to name one |
| HC_FACES_CANDIDATE_THRESHOLD | 0.3 | Similarity from which an unknown face records its closest person |
| HC_FACES_CLUSTER_THRESHOLD | 0.45 | Similarity that joins an unknown cluster |
| HC_FACES_CLUSTER_QUALITY | 0.35 | Mean face quality a track needs to start a cluster |
| HC_FACES_MIN_QUALITY | 0.15 | Lowest quality of a face the pipeline sends |
| HC_FACES_MIN_SCORE | 0.6 | Lowest face detection score |
| HC_FACES_MIN_SIZE | 36 | Smallest face height in pixels at the muxer resolution |

## Status

GET /status on port 8080, with the shared token as a bearer token, returns the pipeline state, per view frame rate, latency, objects, rule counts, tamper
readings and errors, the recorders, the GPU reading, recent events and the face stage's models, gallery, counts and
recent face results. GET /views/{view}/objects returns the tracked
boxes of a view's latest frame, and GET /views/{view}/snapshot.jpg a fresh picture of the view, kept as a zone
reference with reference=1.

## Tests

```
docker build --target test -t home-cameras-analytics:test analytics
docker run --rm home-cameras-analytics:test
```
