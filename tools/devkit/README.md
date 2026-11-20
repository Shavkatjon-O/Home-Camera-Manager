# Development kit

Tools that stand in for a real site. The root README describes the product.

| Folder | Holds |
|---|---|
| camera | A container image that simulates one IP camera with ONVIF, WS-Discovery and RTSP, as camera/README.md describes |

The kit will also hold a simulated site, a sample video script and seed data.

## Run

Build and run the simulated camera as camera/README.md describes.

## Test

The camera tests need no network. Run them from this folder with ruff.toml as the lint configuration:

```
cd tools/devkit/camera && python -m pytest -q
```

## Configuration

The camera takes its settings from CAMERA_ environment variables, listed in camera/README.md.
