# Home cameras TV

An Android TV app that shows the home cameras on the TV on its own. It connects straight to the cameras on the home Wi-Fi, decodes them on the TV and needs nothing from the PC: a grid of every camera, the D-pad moves between tiles, OK opens a tile fullscreen with its sound, Back returns to the grid. In fullscreen of a PTZ camera the arrows move the camera.

## Build

The build needs a JDK 17 or newer (Android Studio's bundled JBR works) and an Android SDK with platform android-37.0 and build-tools 36.0.0. The camera defaults, passwords included, compile in from tv/cameras.local.properties, which git ignores; copy cameras.example.properties to that name and fill in the passwords and addresses. Without it the build falls back to the example file.

```
cp cameras.example.properties cameras.local.properties
export JAVA_HOME=~/Apps/android-studio/jbr
export ANDROID_HOME=~/Android/Sdk
./gradlew testDebugUnitTest assembleDebug assembleRelease
```

The APKs land in app/build/outputs/apk/debug/app-debug.apk and app/build/outputs/apk/release/app-release.apk. The release build is minified and signed with the local debug key, which is enough for sideloading. Both APKs carry the camera passwords, so keep them off shared storage.

## Install

The TV has no adb. Copy app-release.apk to a USB stick, open it in the TV's file manager and allow installing from that source when the TV asks. A newer APK installs over the old one and keeps the settings. The app appears as Home cameras in the launcher.

## Use

- Grid: the D-pad moves a thin outline between tiles and shows the camera name and lens briefly; OK opens that tile fullscreen. Each tile shows a quiet status while it has no picture: Connecting, Reconnecting in N s, Offline, Decoder limit or the login error.
- Fullscreen: Back returns to the grid. The camera's sound plays only here; the label shows a speaker or a crossed speaker. The mute key and the volume keys work as usual, and the icon follows the TV's mute and volume. On a PTZ camera, holding an arrow pans or tilts the whole camera until the key is released, and the label shows Arrows move the camera for 3 s. On other cameras left and right step to the previous or next tile. Channel and zoom keys do nothing, because the V380 protocol has no zoom command.
- Menu or a long press on OK opens Settings, Diagnostics and Reload.
- Settings: OK on an address opens the TV keyboard; confirming applies the address at once. The switch turns a camera off. Find V380 cameras broadcasts a search on the Wi-Fi and moves a V380 camera to the address that answers with its device id. Reset to defaults returns to the compiled values. Settings live in the app's preferences and override the compiled defaults.
- Diagnostics: per camera the state, stream, resolution, frames per second and bit rate received, decoder, decode delay, time to the first picture, audio format and last error; then the device, the app's memory, the decoders in use, every HEVC and AVC decoder with its instance limit and maximum size, and the events log. Up and Down scroll.

## Cameras

| Camera | Protocol | Grid stream | Fullscreen stream | Sound |
|---|---|---|---|---|
| Camera A, Camera B (EZVIZ CS-H3) | RTSP over TCP, digest login | sub, HEVC 768x432 at 10 fps | main, HEVC 2880x1620 at 15 fps | AAC 16 kHz mono |
| PTZ 1 (V380, protocol 32) | V380 LAN on port 8800 | SD, HEVC 640x720 at 15 fps | HD, HEVC 2304x2592 at 15 fps | IMA ADPCM 8 kHz mono, frame type 0x16 |
| PTZ 2 (V380, protocol 31) | V380 LAN on port 8800 | SD, HEVC 640x720 at 15 fps | HD, HEVC 1920x2160 at 15 fps | AAC 8 kHz mono in ADTS, frame type 0x18 |

A V380 picture holds both lenses stacked: lens 1 is the top half and lens 2, the moving lens, the bottom half, each 16:9. The EZVIZ cameras send a keyframe every 4 to 5 s, the V380 cameras every 2 to 3 s; both start a session with a keyframe.

## How it works

- One session and one decoder per camera, never per tile. The grid runs every enabled camera on its small stream; fullscreen stops the grid sessions and opens only that camera's large stream with sound; Back reverses it.
- V380: the app logs in on command 1167 with the password encrypted by AES with a fixed key and then a random key, opens the stream with command 301 (quality, sound on or off) and starts it with 303. For protocol versions above 30 the media key is the auth ticket followed by fixed bytes; video decrypts the first 64 of every 80 bytes, sound decrypts whole 16-byte blocks. Fragments with a 12-byte header assemble into frames with a 16-byte header and an Annex-B payload. PTZ moves and stops are 16-byte commands on the same session; a stop always follows a move, also when the screen changes. Discovery sends NVDEVSEARCH^100 as UDP broadcast to port 10008 and listens on 10009. The port follows PyanSofyan/V380Decoder at commit 8958822 (pull request 17).
- RTSP: a small client does OPTIONS, DESCRIBE, SETUP over interleaved TCP and PLAY, answers digest or basic challenges, sends GET_PARAMETER as keep-alive and rebuilds HEVC or H.264 access units from RTP and AAC frames from RFC 3640 packets. The EZVIZ fragmentation units carry a wrong type in their middle and end fragments, so the type comes from the first fragment.
- Decoding: MediaCodec in asynchronous mode, configured from the first keyframe's parameter sets, renders each frame as soon as it is decoded. The V380 streams declare one frame of reordering they never use, which makes decoders hold every frame back; the app rewrites that SPS field to zero in each keyframe. Hardware decoders come first and software ones after; a camera whose decoder cannot start shows Decoder limit, is logged in Diagnostics and retries every 30 s. A fullscreen stream larger than the hardware decoder allows falls back to the small stream.
- Rendering: every decoder draws into its own SurfaceTexture, and one GLSurfaceView with GLES 2.0 composes the visible tiles, each a quad sampling its lens of a texture, letterboxed to keep the aspect. Compose for TV draws the outline, labels and status on top. Decoders, sessions and GL textures are released when the app stops.
- Reconnects: each camera retries on its own after 1, 2, 5, 10 and then every 30 s, and a camera that cannot be reached shows Offline. A V380 camera that does not answer at start triggers one automatic discovery. Losing and regaining the network reconnects everything.
- Sound: AAC decodes through MediaCodec, ADPCM and G.711 A-law in Kotlin, and all of it plays through an AudioTrack with a 160 ms buffer. Leaving fullscreen stops it at once.

## Layout

- app/src/main/kotlin/uz/home/cameras/tv/camera: the camera model, the compiled defaults and the stored overrides.
- app/src/main/kotlin/uz/home/cameras/tv/v380: the V380 protocol: packets, crypto, frames, Annex-B and SPS parsing, sound codecs, PTZ, discovery and the session client.
- app/src/main/kotlin/uz/home/cameras/tv/rtsp: SDP, RTSP messages and digest, RTP depacketizers and the RTSP client.
- app/src/main/kotlin/uz/home/cameras/tv/stream: the per-camera feed loop with reconnects, the MediaCodec video decoder, sound output and the decoder inventory.
- app/src/main/kotlin/uz/home/cameras/tv/render: geometry, the shader and the GL compositor.
- app/src/main/kotlin/uz/home/cameras/tv/wall: the wall plan and the controller that runs the feeds for the grid or one fullscreen tile.
- app/src/main/kotlin/uz/home/cameras/tv/control: remote key mapping, grid focus movement, long press and fullscreen key actions.
- app/src/main/kotlin/uz/home/cameras/tv/ui: Compose for TV overlays and screens.
- app/src/test: unit tests for the V380 packets, crypto, frames, SPS rewrite and sound codecs, a V380 session against a local fake camera, the RTSP parsing and depacketizers, the camera config, the wall plan, geometry, key handling and the retry policy.

Debug builds log sessions, first-picture times and PTZ commands under the Feed tag.
