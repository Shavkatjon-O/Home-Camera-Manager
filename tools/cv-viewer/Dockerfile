FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      libgl1 libglib2.0-0 libgl1-mesa-dri \
      libx11-6 libxext6 libxrender1 libsm6 \
      libxcb1 libxcb-xinerama0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
      libxcb-randr0 libxcb-render-util0 libxcb-render0 libxcb-shape0 \
      libxcb-shm0 libxcb-sync1 libxcb-xfixes0 libxcb-util1 \
      libxkbcommon0 libxkbcommon-x11-0 libfontconfig1 libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir opencv-python==4.11.0.86 numpy

WORKDIR /app
COPY cv_viewer.py /app/cv_viewer.py
ENTRYPOINT ["python", "cv_viewer.py"]
