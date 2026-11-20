#!/bin/sh
#
# Starts the simulated camera: writes the go2rtc configuration for the main and optional sub stream from the
# CAMERA_ environment variables, starts the ONVIF and discovery responder in the background and runs go2rtc.
# Globals:
#   CAMERA_MAIN: video file of the main stream
#   CAMERA_SUB: video file of the sub stream, none when empty
#   CAMERA_USERNAME: login for RTSP, default admin
#   CAMERA_PASSWORD: password for RTSP, no authentication when empty

set -eu

mkdir -p /config
config=/config/go2rtc.yaml

{
  echo "api:"
  echo "  listen: \"127.0.0.1:1984\""
  echo "rtsp:"
  echo "  listen: \":554\""
  if [ -n "${CAMERA_PASSWORD:-}" ]; then
    echo "  username: \"${CAMERA_USERNAME:-admin}\""
    echo "  password: \"${CAMERA_PASSWORD}\""
  fi
  echo "webrtc:"
  echo "  listen: \"\""
  echo "ffmpeg:"
  echo "  loop: \"-re -stream_loop -1 -i {input}\""
  echo "streams:"
  echo "  main: \"ffmpeg:${CAMERA_MAIN}#input=loop#video=copy\""
  if [ -n "${CAMERA_SUB:-}" ]; then
    echo "  sub: \"ffmpeg:${CAMERA_SUB}#input=loop#video=copy\""
  fi
} > "$config"

python3 /usr/local/lib/camera/responder.py &

exec go2rtc -config "$config"
