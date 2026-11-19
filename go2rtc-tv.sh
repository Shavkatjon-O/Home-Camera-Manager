#!/bin/sh
set -eu
url="http://backend:8000/internal/tv/streams/$1"
args=$(curl -fsS --max-time 10 "$url")
self=$$
errors=$(mktemp -u /tmp/tv-XXXXXX)
mkfifo "$errors"
(
    while IFS= read -r line; do
        case $line in
            *"Error opening input file rtsp://127.0.0.1:8554/"*)
                source=${line##*8554/}
                curl -fsS --max-time 5 -X POST "$url/failed?source=${source%%\?*}" || true
                ;;
        esac
    done
    rm -f "$errors"
) <"$errors" >/dev/null 2>&1 &
(
    while sleep 5 && kill -0 "$self"; do
        current=$(curl -fsS --max-time 10 "$url?poll=true") || continue
        if [ "$current" != "$args" ]; then
            kill "$self"
            exit 0
        fi
    done
) </dev/null >/dev/null 2>&1 &
IFS='
'
set -f
exec ffmpeg $args "$2" 2>"$errors"
