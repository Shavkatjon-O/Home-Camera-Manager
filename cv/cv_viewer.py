import os
import sys
import time
import math
import threading
import argparse

os.environ.setdefault("OPENCV_FFMPEG_CAPTURE_OPTIONS", "rtsp_transport;tcp")

import cv2
import numpy as np

PW = os.environ.get("CAMERA_PASSWORD", "")
STREAM = os.environ.get("STREAM", "main")            # main -> 101, sub -> 102
CH = "101" if STREAM == "main" else "102"
SCREEN_W = int(os.environ.get("SCREEN_W", "1920"))
SCREEN_H = int(os.environ.get("SCREEN_H", "1080"))

HOSTS = [host.strip() for host in os.environ.get("CV_CAMERA_HOSTS", "192.168.1.104,192.168.1.106").split(",") if host.strip()]

CAMERAS = [
    (f"Camera {chr(65 + index)}", f"rtsp://admin:{PW}@{host}:554/Streaming/Channels/{CH}")
    for index, host in enumerate(HOSTS)
]

BG = (16, 16, 20)


class Camera(threading.Thread):
    def __init__(self, name, url):
        super().__init__(daemon=True)
        self.name = name
        self.url = url
        self.lock = threading.Lock()
        self.frame = None
        self.ts = 0.0
        self.connected = False
        self.stop = False

    def run(self):
        while not self.stop:
            cap = cv2.VideoCapture(self.url, cv2.CAP_FFMPEG)
            try:
                cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
            except Exception:
                pass
            if not cap.isOpened():
                self.connected = False
                time.sleep(2.0)
                continue
            self.connected = True
            fails = 0
            while not self.stop:
                ok, frame = cap.read()
                if not ok or frame is None:
                    fails += 1
                    if fails > 30:
                        break
                    continue
                fails = 0
                with self.lock:
                    self.frame = frame
                    self.ts = time.time()
            cap.release()
            self.connected = False
            time.sleep(1.0)

    def latest(self):
        with self.lock:
            if self.frame is None:
                return None, self.ts
            return self.frame, self.ts


def fit(frame, cw, ch):
    h, w = frame.shape[:2]
    scale = min(cw / w, ch / h)
    nw, nh = max(1, int(round(w * scale))), max(1, int(round(h * scale)))
    interp = cv2.INTER_AREA if scale < 1 else cv2.INTER_LINEAR
    resized = cv2.resize(frame, (nw, nh), interpolation=interp)
    canvas = np.empty((ch, cw, 3), np.uint8)
    canvas[:] = BG
    y0, x0 = (ch - nh) // 2, (cw - nw) // 2
    canvas[y0:y0 + nh, x0:x0 + nw] = resized
    return canvas


def label(img, text, ok):
    h, w = img.shape[:2]
    cv2.rectangle(img, (0, h - 34), (w, h), (0, 0, 0), -1)
    color = (80, 220, 120) if ok else (120, 120, 120)
    cv2.circle(img, (18, h - 17), 6, color, -1)
    cv2.putText(img, text, (34, h - 11), cv2.FONT_HERSHEY_SIMPLEX,
                0.7, (235, 235, 235), 1, cv2.LINE_AA)
    return img


def blank(cw, ch, text):
    img = np.empty((ch, cw, 3), np.uint8)
    img[:] = BG
    cv2.putText(img, text, (cw // 2 - 90, ch // 2),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (120, 120, 120), 1, cv2.LINE_AA)
    return img


def compose(cams, total_w, total_h):
    n = len(cams)
    cols = math.ceil(math.sqrt(n))
    rows = math.ceil(n / cols)
    cw, ch = total_w // cols, total_h // rows
    now = time.time()
    cells = []
    for c in cams:
        frame, ts = c.latest()
        live = c.connected and frame is not None and (now - ts) < 3.0
        if frame is None:
            cell = blank(cw, ch, "Connecting..." if not c.connected else "No signal")
        else:
            cell = fit(frame, cw, ch)
        cells.append(label(cell, f"{c.name}    {time.strftime('%H:%M:%S')}", live))
    while len(cells) < rows * cols:
        cells.append(blank(cw, ch, ""))
    row_imgs = [cv2.hconcat(cells[r * cols:(r + 1) * cols]) for r in range(rows)]
    return cv2.vconcat(row_imgs) if rows > 1 else row_imgs[0]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--snapshot", metavar="PATH",
                    help="grab one composed frame, save it, and exit")
    ap.add_argument("--size", default=f"{SCREEN_W}x{SCREEN_H}",
                    help="total grid size WxH (defaults to the screen)")
    ap.add_argument("--wait", type=float, default=10.0)
    args = ap.parse_args()

    tw, th = (int(x) for x in args.size.lower().split("x"))
    cams = [Camera(n, u) for n, u in CAMERAS]
    for c in cams:
        c.start()

    if args.snapshot:
        deadline = time.time() + args.wait
        while time.time() < deadline:
            if all(c.latest()[0] is not None for c in cams):
                break
            time.sleep(0.2)
        cv2.imwrite(args.snapshot, compose(cams, tw, th))
        print("saved", args.snapshot)
        for c in cams:
            c.stop = True
        return

    win = "Home Cameras"
    cv2.namedWindow(win, cv2.WINDOW_NORMAL)
    cv2.resizeWindow(win, tw, th)
    full = False
    while True:
        cv2.imshow(win, compose(cams, tw, th))
        k = cv2.waitKey(30) & 0xFF
        if k in (ord("q"), 27):
            break
        if k == ord("f"):
            full = not full
            cv2.setWindowProperty(win, cv2.WND_PROP_FULLSCREEN,
                                  cv2.WINDOW_FULLSCREEN if full else cv2.WINDOW_NORMAL)
        if cv2.getWindowProperty(win, cv2.WND_PROP_VISIBLE) < 1:
            break
    for c in cams:
        c.stop = True
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
