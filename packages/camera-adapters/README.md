# Camera adapters

The Python package camera_adapters: one adapter per kind of camera behind one interface, split into capabilities (control, imaging, events, playback, maintenance, provisioning). An adapter always fingerprints a device, identifies it, finds its streams and reads its labels; a capability manifest says what each camera really supports. The API imports the package to reach cameras directly, and the on-site connector uses it on a site's network. The package imports nothing from services or apps.

## Layout

| Module | Role |
|---|---|
| base | Adapter interface, capabilities and shared types |
| registry | Picks the adapter of a device from its fingerprint and the catalog; loads third-party adapters from the entry point group smart_surveillance.camera_adapters |
| catalog | Known camera models, in catalog/models.yaml |
| onvif, rtsp, ezviz, v380 | Built-in adapters |
| v380 client, streamer, pipe, control, router | Our V380 LAN protocol client, written from docs/protocols/v380.md: sessions, reconnects, the Annex-B output go2rtc reads from an exec source, and the control socket |
| v380 relay, go2rtc | The relay that serves one V380 camera over RTSP, and the go2rtc exec source of a camera |
| fingerprint, classifier, sweep | Device fingerprinting, classification and subnet sweep |
| manifest | Capability manifest of a camera |

## Run

The package is a uv workspace member and is installed with the API image. Use it from Python:

```
from camera_adapters.registry import default_registry
```

## Test

Run from the repository root:

```
docker run --rm -u $(id -u):$(id -g) -e HOME=/tmp -e UV_PROJECT_ENVIRONMENT=/tmp/venv -e UV_CACHE_DIR=/tmp/uv-cache -v $PWD:/repo -w /repo/packages/camera-adapters ghcr.io/astral-sh/uv:python3.13-bookworm-slim sh -c "uv sync --frozen --all-packages && uv run --frozen ruff check . && uv run --frozen pytest -q"
```

## Configuration

The package reads no environment variables. Adapters take their address, port and credentials through the Target they are given.
