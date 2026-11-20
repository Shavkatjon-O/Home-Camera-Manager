# Simulated camera

An image that simulates one IP camera on a simulated site LAN. go2rtc serves looping video files over RTSP on port 554, and a standard-library Python responder answers ONVIF SOAP calls on port 80 and WS-Discovery probes on UDP port 3702. Several containers from the image, each with its own address, form a site that the connector agent can find by multicast discovery and by a port sweep.

The responder answers GetSystemDateAndTime, GetDeviceInformation, GetCapabilities, GetServices, GetProfiles, GetStreamUri and, with PTZ, ContinuousMove and Stop. Every call except GetSystemDateAndTime needs a WS-Security digest when a password is set. Streams are served at rtsp://ADDRESS:554/main and, when a sub stream is set, /sub.

Build and run:

    docker build -t smart-surveillance-dev-camera:local .
    docker run -d --memory=1g --network site --ip 172.31.250.11 -v ./samples:/samples:ro \
      -e CAMERA_ADDRESS=172.31.250.11 -e CAMERA_MAIN=/samples/main.mp4 smart-surveillance-dev-camera:local

| Variable | Default | Meaning |
|---|---|---|
| CAMERA_ADDRESS | required | IPv4 address of the container on the site LAN |
| CAMERA_MAIN | required | Video file for the main stream |
| CAMERA_SUB | empty | Video file for the sub stream, no sub profile when empty |
| CAMERA_NAME | camera-ADDRESS | Name in the discovery scopes |
| CAMERA_MANUFACTURER | Simulated | Manufacturer reported over ONVIF |
| CAMERA_MODEL | SIM-1 | Model reported over ONVIF |
| CAMERA_SERIAL | SIM-ADDRESS | Serial number, also the source of the discovery endpoint id |
| CAMERA_USERNAME | admin | User name for ONVIF and RTSP |
| CAMERA_PASSWORD | empty | Password, empty means no authentication |
| CAMERA_PTZ | false | true adds the PTZ service and PTZ configurations |
| CAMERA_MAIN_SIZE | 1280x720 | Resolution reported for the main profile |
| CAMERA_SUB_SIZE | empty | Resolution reported for the sub profile |

Tests run with pytest from this folder and need no network.
