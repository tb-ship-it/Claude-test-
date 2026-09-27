#!/usr/bin/env python3
"""Cuts the reel's soundtrack from "Boardroom Drift" and adds two sound-design touches.

The track sits on a fixed 130.2 BPM grid (beat 0.4608572s). The cut starts on the
downbeat of the break bar at 42.434s, so the drop lands as the page opens at 1.843s,
and every visual cue in index.html is placed on this same grid.

    python3 audio.py path/to/Boardroom_Drift.mp3     -> reel.wav (48 kHz, 16-bit stereo)

Needs numpy, scipy and an ffmpeg binary (FFMPEG env var, imageio-ffmpeg, or PATH).
"""
import os
import subprocess
import sys
import numpy as np
from scipy.signal import butter, sosfilt
from scipy.io import wavfile

SR = 48000
DUR = 15.0
N = int(SR * DUR)
BEAT = 0.4608571671960374
START = 0.9567618236322547 + 90 * BEAT          # downbeat of the break bar, 42.434s
T_GLOBE, T_END = 12 * BEAT, 22 * BEAT
CONV = T_GLOBE + 8 * BEAT                          # globe collapses into one point
CLICK = T_END + 8 * BEAT                           # the CTA click
rng = np.random.default_rng(7)


def ffmpeg():
    if os.environ.get('FFMPEG'):
        return os.environ['FFMPEG']
    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except ImportError:
        return 'ffmpeg'


def load(path):
    raw = subprocess.run([ffmpeg(), '-v', 'error', '-ss', f'{START:.6f}', '-t', f'{DUR + .5}', '-i', path,
                          '-f', 'f32le', '-ac', '2', '-ar', str(SR), '-'], capture_output=True, check=True).stdout
    x = np.frombuffer(raw, np.float32).reshape(-1, 2).astype(np.float64)[:N]
    return np.pad(x, ((0, N - len(x)), (0, 0)))


def T(n): return np.arange(n) / SR


def whoosh(dur, f0, f1):
    """Band-passed noise gliding f0 -> f1 under a bell envelope, panned left to right."""
    n = int(dur * SR); x = rng.standard_normal(n); y = np.zeros(n); blk = 256; zi = None
    for b in range(0, n, blk):
        fc = f0 * (f1 / f0) ** (b / n)
        s = butter(2, [fc / 1.5, min(fc * 1.5, SR * .45)], 'band', fs=SR, output='sos')
        zi = np.zeros((s.shape[0], 2)) if zi is None else zi
        y[b:b + blk], zi = sosfilt(s, x[b:b + blk], zi=zi)
    u = T(n) / dur; y *= np.sin(np.pi * u) ** 2
    a = (u * 1.6 - .8 + 1) * np.pi / 4
    return np.stack([y * np.cos(a), y * np.sin(a)], 1) * np.sqrt(2)


def click():
    n = int(.04 * SR); t = T(n)
    hp = butter(2, 2500, 'high', fs=SR, output='sos')
    s = sosfilt(hp, rng.standard_normal(n)) * np.exp(-t * 600) * .6 + np.sin(2 * np.pi * 2400 * t) * np.exp(-t * 300) * .5
    return np.stack([s, s], 1)


def put(mix, sig, t, g):
    s = int(round(t * SR)); e = min(N, s + len(sig)); mix[s:e] += sig[:e - s] * g


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    mix = load(sys.argv[1])
    ref = np.sqrt((mix ** 2).mean())
    put(mix, whoosh(.9, 300, 5000), CONV + .1, ref * .9)   # the globe implodes, the page irises open
    put(mix, click(), CLICK, ref * 1.2)                     # the cursor clicks "Let's talk"
    fade = np.ones(N); fi, fo = int(.005 * SR), int(.25 * SR)
    fade[:fi] = np.linspace(0, 1, fi); fade[-fo:] = np.linspace(1, 0, fo) ** 1.5
    mix *= fade[:, None]
    peak = np.abs(mix).max()
    if peak > .89:
        mix *= .89 / peak
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'reel.wav')
    wavfile.write(out, SR, (mix * 32767).astype(np.int16))
    print(f'wrote {out}  peak {20 * np.log10(np.abs(mix).max()):.1f} dBFS')
