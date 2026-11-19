# Analytics

Video analytics for the home cameras on NVIDIA DeepStream: people, vehicle and animal detection, tracking, zones,
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
| identity | detector, tracker and rules for people; reserves the face stage |
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

## Run

Download the models into the model folder, then start the development stack on the main stack's network:

```
scripts/download-models.sh
docker compose -f analytics/compose.dev.yml --env-file .env up -d --build
curl -s 127.0.0.1:8760/status
```

The development stack reads its views from analytics/config.local.json, which stays out of git. The first start
builds the TensorRT engine into the engine volume, which takes about a minute.

## Configuration

| Name | Default | Meaning |
|---|---|---|
| HC_ANALYTICS_MODELS_DIR | analytics/models | Model folder mounted read-only at /models |
| HC_ANALYTICS_DETECTOR | rfdetr-medium | Shared detector |
| HC_ANALYTICS_FPS | 8 | Analysis rate of views that set none |
| HC_ANALYTICS_CLIP_ENCODER | auto | auto, h264_nvenc, libx264 or copy |
| HC_ANALYTICS_CLIP_BEFORE | 5 | Seconds a clip starts before its event |
| HC_ANALYTICS_CLIP_AFTER | 5 | Seconds a clip runs after its event |
| HC_ANALYTICS_CLIP_MAX | 60 | Longest clip in seconds |
| HC_ANALYTICS_BUFFER_SECONDS | 120 | Seconds of segments kept per camera |
| HC_TIMEZONE | UTC | Time zone of schedules |

## Status

GET /status on port 8080 returns the pipeline state, per view frame rate, latency, objects, rule counts, tamper
readings and errors, the recorders, the GPU reading and recent events. GET /views/{view}/objects returns the tracked
boxes of a view's latest frame.

## Tests

```
docker build --target test -t home-cameras-analytics:test analytics
docker run --rm home-cameras-analytics:test
```
