# Simulated V380 camera

A standard-library Python simulator of a V380 camera, built from the simulator section of docs/protocols/v380.md. It answers discovery on UDP port 10008, logs clients in on TCP port 8800 with the encrypted password field, answers the stream login, waits for the start request and sends encrypted, fragmented H.265 or H.264 video and IMA ADPCM, AAC or A-law audio at the stream's rates. It reads PTZ, light, siren and picture records at any time, keeps a simulated pan and tilt position and prints every event as a JSON line on standard output. The client tests, the TV tests and the development kit use it in place of real cameras.

| File | Role |
|---|---|
| simulator.py | The simulator and its command line |
| aes.py | AES-128 in plain Python, so the simulator needs no packages |
| media.py | Access units from Annex-B files or generated ones, and generated audio |
| entrypoint.sh | Container entry point: encodes a sample video into main and sub streams and starts the simulator |
| Dockerfile | Image of the development kit's V380 cameras |
| test_client.py | The V380 client against the simulator: the transcript, every fault and the go2rtc output |
| test_adapter.py | The V380 adapter and the relay against the simulator |

## Run

```
python3 tools/devkit/v380/simulator.py --port 8800 --video main.h265 --sub-video sub.h265 --audio adpcm
python3 tools/devkit/v380/simulator.py --transcript --port 0 --discovery-port 0
```

Without a video file the simulator generates access units with real parameter sets and placeholder slices, which exercise the protocol but do not decode. A file must be an H.265 or H.264 Annex-B stream that repeats its parameter sets before every key frame and has no B-frames, as ffmpeg writes it:

```
ffmpeg -i sample.mp4 -an -c:v libx265 -x265-params keyint=30:bframes=0:repeat-headers=1 -f hevc main.h265
```

--transcript serves exactly the session transcript of the specification with ticket 0x0badf00d, for byte-for-byte checks. The first line on standard output is {"event": "listening", "port": N, "discovery_port": M}, so a test can start it on port 0.

In the development kit, scripts/devkit.sh up starts the cameras v380-camera-porch at 172.31.250.21, device version 32 with ADPCM audio, and v380-camera-garage at 172.31.250.22, device version 31 with AAC audio, on the home LAN, with the device ids 12345678 and 23456789 and the password SSS_DEV_CAMERA_PASSWORD. The relays v380-relay-ptz-1 and v380-relay-ptz-2 serve them to the stack.

## Faults

Each --fault switch, repeatable and also read from V380_SIM_FAULTS as a comma-separated list, makes the simulator misbehave; media faults apply to every --fault-every frame, 30 by default.

| Fault | Effect |
|---|---|
| refuse-login=CODE | Refuses every login with CODE, 1012 by default |
| refuse-stream | Answers the stream login with -11 |
| split-reply | Sends the stream login reply in two TCP segments |
| full-reply | Sends the full 412-byte stream login reply |
| silence=SECONDS | Sends nothing for SECONDS, 16 by default |
| close-mid-frame | Closes the connection inside a fragment |
| missing-fragment | Leaves out a fragment of a frame |
| repeated-fragment | Sends a fragment twice |
| count-change | Changes the fragment count within a frame |
| invalid-header | Puts an invalid header and junk before a frame |
| unknown-type | Puts a fragment of type 0x5b inside a frame |
| leading-bytes | Puts two bytes before the start code |
| clear-media | Reports device version 30 and sends clear media |
| comm21 | Reports communication version 21 and encrypts video in whole blocks |
| h264 | Sends generated H.264 video |
| parameter-change | Switches between the main and sub parameter sets at key frames |
| single-session | Drops the open session when a second one starts |
| interleave-audio | Puts an audio frame between two fragments of a video frame |

## Test

The tests need the camera_adapters package and no network beyond loopback:

```
cd tools/devkit/v380
uv run --package camera-adapters pytest -q
```

## Configuration

| Variable | Default | Meaning |
|---|---|---|
| V380_SIM_HOST | 0.0.0.0 | Listening address |
| V380_SIM_PORT | 8800 | TCP port |
| V380_SIM_DISCOVERY_PORT | 10008 | UDP discovery port, 0 for none |
| V380_SIM_ADDRESS | 127.0.0.1 | Address in discovery replies |
| V380_SIM_MAC | 02:00:00:38:00:01 | Hardware address in discovery replies |
| V380_SIM_DEVICE_ID | 12345678 | Device id |
| V380_SIM_USERNAME | admin | User name |
| V380_SIM_PASSWORD | secret123 | Password |
| V380_SIM_DEVICE_VERSION | 32 | Device version |
| V380_SIM_COMM_VERSION | 20 | Communication version |
| V380_SIM_VIDEO | empty | Annex-B file of the main stream |
| V380_SIM_SUB_VIDEO | empty | Annex-B file of the sub stream, the main file when empty |
| V380_SIM_AUDIO | adpcm | none, adpcm, alaw or aac |
| V380_SIM_AAC_FILE | empty | ADTS file for aac audio, placeholder frames when empty |
| V380_SIM_FPS | 15 | Frame rate |
| V380_SIM_FAULTS | empty | Fault switches |
| V380_SIM_SOURCE | empty | Sample video the container entry point encodes |
