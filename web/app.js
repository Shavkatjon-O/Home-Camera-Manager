import { VideoRTC } from './video-rtc.js';

const CAMERAS = [
  { id: 'cam_a', name: 'Camera A', ip: '192.168.1.104' },
  { id: 'cam_b', name: 'Camera B', ip: '192.168.1.106' },
];

// video-rtc.js ships only the base VideoRTC class; register the element before use.
if (!customElements.get('video-stream')) {
  customElements.define('video-stream', class extends VideoRTC {
    oninit() {
      super.oninit();
      // Autoplay only works muted; keep the wall chrome-free.
      this.video.muted = true;
      this.video.autoplay = true;
      this.video.controls = false;
      this.video.setAttribute('playsinline', '');
    }
  });
}

const grid = document.getElementById('grid');
const els = [];

function tileFor(cam) {
  const tile = document.createElement('div');
  tile.className = 'tile';

  const video = document.createElement('video-stream');
  video.mode = 'mse';
  video.background = true;
  const url = new URL('api/ws', location.href);
  url.protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
  url.searchParams.set('src', cam.id);
  video.src = url;
  tile.appendChild(video);

  const label = document.createElement('div');
  label.className = 'label';
  label.innerHTML =
    '<span class="live"><i></i>LIVE</span>' +
    '<span class="name">' + cam.name + '</span>' +
    '<span class="ip">' + cam.ip + '</span>';
  tile.appendChild(label);

  const hint = document.createElement('div');
  hint.className = 'hint';
  hint.textContent = 'double-click for fullscreen';
  tile.appendChild(hint);

  tile.addEventListener('dblclick', () => {
    if (document.fullscreenElement) document.exitFullscreen();
    else tile.requestFullscreen();
  });

  els.push({ cam, tile, video, label });
  return tile;
}

CAMERAS.forEach(c => grid.appendChild(tileFor(c)));

// Layout toggle
const layoutBtn = document.getElementById('layoutBtn');
layoutBtn.addEventListener('click', () => {
  grid.classList.toggle('stack');
  layoutBtn.textContent = grid.classList.contains('stack') ? 'Stacked' : 'Grid';
});

// Mute toggle (streams start muted so autoplay is allowed)
let muted = true;
const muteBtn = document.getElementById('muteBtn');
function applyMute() {
  muteBtn.textContent = muted ? 'Muted' : 'Sound on';
  muteBtn.classList.toggle('active', !muted);
  els.forEach(e => { const v = e.video.video; if (v) v.muted = muted; });
}
muteBtn.addEventListener('click', () => { muted = !muted; applyMute(); });

// Whole-wall fullscreen
document.getElementById('fsBtn').addEventListener('click', () => {
  if (document.fullscreenElement) document.exitFullscreen();
  else document.documentElement.requestFullscreen();
});

// Clock
const clock = document.getElementById('clock');
function tick() {
  clock.textContent = new Date().toLocaleString('en-GB', { hour12: false });
}
tick(); setInterval(tick, 1000);

// Keep muted state applied as inner <video> elements appear
setInterval(applyMute, 2000);
