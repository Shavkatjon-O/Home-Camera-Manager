#!/bin/sh
#
# Starts a simulated V380 camera: encodes the sample video given by V380_SIM_SOURCE into short H.265 Annex-B
# main and sub streams with in-band parameter sets, then runs the simulator on them. Without a source the
# simulator serves generated placeholder video. The simulator reads its other V380_SIM_ variables itself.
# Globals:
#   V380_SIM_SOURCE: sample video to encode, none when empty
#   V380_SIM_FPS: frame rate, default 15

set -eu

work=/tmp/v380
mkdir -p "$work"
fps=${V380_SIM_FPS:-15}

encode() {
  size=$1
  output=$2
  ffmpeg -hide_banner -loglevel error -y -stream_loop -1 -i "$V380_SIM_SOURCE" -t 20 -an \
    -vf "scale=$size,fps=$fps" -threads 2 -c:v libx265 -preset ultrafast \
    -x265-params "keyint=$((fps * 2)):bframes=0:repeat-headers=1:pools=2:frame-threads=1:rc-lookahead=5:log-level=error" \
    -f hevc "$output" 2>/dev/null
}

if [ -n "${V380_SIM_SOURCE:-}" ] && [ -f "$V380_SIM_SOURCE" ]; then
  encode 960:1080 "$work/main.h265"
  encode 640:720 "$work/sub.h265"
  exec python3 /usr/local/lib/v380/simulator.py --video "$work/main.h265" --sub-video "$work/sub.h265" "$@"
fi

exec python3 /usr/local/lib/v380/simulator.py "$@"
