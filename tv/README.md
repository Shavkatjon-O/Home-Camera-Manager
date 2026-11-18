# Home cameras TV

An Android TV app that shows the home cameras on the TV in real time: the composed wall stream from the home-cameras stack, and any tile fullscreen with PTZ control. The TV joins the home Wi-Fi and talks to the stack on the home network address only.

## Build

The build needs a JDK 17 or newer (Android Studio's bundled JBR works) and an Android SDK with platform android-37.0 and build-tools 36.0.0.

```
export JAVA_HOME=~/Apps/android-studio/jbr
export ANDROID_HOME=~/Android/Sdk
./gradlew testDebugUnitTest assembleDebug assembleRelease
```

The APKs land in app/build/outputs/apk/debug/app-debug.apk and app/build/outputs/apk/release/app-release.apk. The release build is minified and signed with the local debug key, which is enough for sideloading.

## Install

Turn on developer options and network debugging on the TV, then install over the network:

```
adb connect <tv-ip>:5555
adb install -r app/build/outputs/apk/release/app-release.apk
```

The app appears on the TV home screen as Home cameras.

## Use

- Setup: the server address defaults to http://192.168.1.219:8750; OK on the field opens the TV keyboard to change it. Continue shows a 6-digit code; enter it in the web app under Cameras, TV. The code renews itself when it expires. Once approved the TV keeps its device token and opens the wall on every start.
- Wall: the D-pad moves a thin outline between tiles and shows the tile label briefly; OK opens that tile fullscreen. Menu or a long press on OK opens Reload, Server and pairing, and About.
- Tile: Back returns to the wall. On a PTZ camera the arrows pan and tilt while held, and channel up or down, fast-forward or rewind zoom. On other cameras left and right step to the previous or next tile.
- Errors show as one quiet status line over black. The app reconnects on player errors, stream end, stalls and network loss after 1, 2, 5 and then every 10 s, and fetches the config again each time. A 401 from the API drops the token and returns to pairing.

## Server contract

- POST /api/v1/tv/pairings with {"device_name"} returns {id, code, expires_at}; GET /api/v1/tv/pairings/{id} returns {status, token}, polled every 2 s.
- GET /api/v1/tv/config with the Bearer device token returns {wall: {url, cols, rows}, tiles: [{index, label, camera_uuid, camera_name, lens, ptz, url}]}. A tile's index is its slot in the wall grid, filled by column: column index / rows, row index % rows.
- POST /api/v1/tv/ptz/{camera_uuid}/move with {pan, tilt, zoom} on key down and POST /api/v1/tv/ptz/{camera_uuid}/stop on key up, both with the Bearer token.

## Playback

One ExoPlayer instance plays both the wall and the tiles, so switching only swaps the media source. RTSP runs over TCP with credentials from the URL and a 10 s RTP timeout. Buffers stay small (500 ms minimum, 2000 ms maximum, 100 ms to start, 300 ms after a rebuffer), and the video renders on a SurfaceView, scaled to fit. Every 250 ms the player checks how far it sits behind live: above 500 ms it plays at 1.5x until it is under 250 ms, above 3 s it reconnects, and a stall longer than 4 s counts as a failure. Debug builds log the offset, first-frame time and failures under the LivePlayer tag:

```
adb logcat -s LivePlayer
```

## Layout

- app/src/main/kotlin/uz/home/cameras/tv/data: JSON models, parsing, settings and the HTTP API client.
- app/src/main/kotlin/uz/home/cameras/tv/pairing: the pairing loop.
- app/src/main/kotlin/uz/home/cameras/tv/player: the low-latency player, reconnect backoff, drift policy and the viewer session.
- app/src/main/kotlin/uz/home/cameras/tv/control: remote key mapping, wall focus movement, long press and tile key actions.
- app/src/main/kotlin/uz/home/cameras/tv/ui: Compose for TV screens and overlays.
- app/src/test: unit tests for config parsing, key handling and the playback policies.
