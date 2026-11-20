# go2rtc

The configuration of the go2rtc container that restreams every camera, transcodes for the browser and composes the TV wall. The root README describes the product.

| File | Role |
|---|---|
| go2rtc.yaml | Main configuration: RTSP server, WebRTC for the apps on SSS_LAN_BIND port 8555, h264 transcode template and the TV exec streams |
| go2rtc.jetson.yaml | The same for a Jetson, with software x264 transcoding |
| go2rtc-tv.sh | Exec source that asks the API for the ffmpeg arguments of a TV stream and restarts when they change |

## Run

The compose service go2rtc mounts go2rtc.yaml read-only at /config/go2rtc.yaml and go2rtc-tv.sh at /config/tv.sh. Camera streams are added at runtime by the API and are never written to go2rtc.yaml, because go2rtc stores stream URLs with camera passwords in its config.

```
docker compose up -d go2rtc
docker compose logs -f go2rtc
```

## Test

Check the script syntax and the compose file:

```
sh -n deploy/go2rtc/go2rtc-tv.sh
docker compose config -q
```

## Configuration

| Variable | Default | Meaning |
|---|---|---|
| SSS_TV_RTSP_USERNAME | tv | RTSP user for clients outside the stack |
| SSS_TV_RTSP_PASSWORD | required | RTSP password for those clients |
| SSS_LAN_BIND | required | LAN address the RTSP port 8554 is published on |
