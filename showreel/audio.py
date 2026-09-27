#!/usr/bin/env python3
"""Synthesises the 15-second, 128 BPM score for the motion reel.

Every sound is placed on the same beat grid as index.html, so picture and sound
lock without manual syncing. Pure numpy/scipy, no samples.

    python3 audio.py            -> reel.wav (48 kHz, 16-bit stereo)
"""
import os
import numpy as np
from scipy.signal import butter, sosfilt, fftconvolve
from scipy.io import wavfile

SR = 48000
DUR = 15.0
N = int(SR * DUR)
BPM = 128
BEAT = 60 / BPM
BAR = 4 * BEAT
CUT = BEAT / 2
rng = np.random.default_rng(2026)

drums = np.zeros((N, 2))   # not ducked
music = np.zeros((N, 2))   # sidechained to the kick
send = np.zeros((N, 2))    # reverb send


# ---------------------------------------------------------------- helpers
def T(n): return np.arange(n) / SR
def midi(m): return 440 * 2 ** ((m - 69) / 12)
def sos(kind, fc, order=2): return butter(order, fc, kind, fs=SR, output='sos')
def lp(x, fc, o=2): return sosfilt(sos('low', fc, o), x)
def hp(x, fc, o=2): return sosfilt(sos('high', fc, o), x)
def bp(x, lo, hi, o=2): return sosfilt(sos('band', [lo, hi], o), x)
def noise(n): return rng.standard_normal(n)
def saw(f, t, ph=0.0): return 2 * ((f * t + ph) % 1) - 1


def put(sig, t, g=1.0, pan=0.0, rev=0.0, bus=None):
    """Place a mono (or stereo) signal at time t with equal-power pan and a reverb send."""
    bus = drums if bus is None else bus
    s = int(round(t * SR))
    if sig.ndim == 1:
        a = (pan + 1) * np.pi / 4
        sig = np.stack([sig * np.cos(a), sig * np.sin(a)], 1) * np.sqrt(2)
    if s < 0:
        sig, s = sig[-s:], 0
    sig = sig[: max(0, N - s)] * g
    bus[s:s + len(sig)] += sig
    if rev:
        send[s:s + len(sig)] += sig * rev


def sweep(x, f0, f1, kind='band', block=256):
    """Time-varying filter: cutoff glides exponentially from f0 to f1 across x."""
    y = np.zeros_like(x)
    nb = (len(x) + block - 1) // block
    zi = None
    for b in range(nb):
        fc = f0 * (f1 / f0) ** (b / max(1, nb - 1))
        s = sos(kind, [fc / 1.5, min(fc * 1.5, SR * .45)] if kind == 'band' else min(fc, SR * .45))
        if zi is None:
            zi = np.zeros((s.shape[0], 2))
        y[b * block:(b + 1) * block], zi = sosfilt(s, x[b * block:(b + 1) * block], zi=zi)
    return y


# ------------------------------------------------------------ instruments
def kick():
    n = int(.5 * SR); t = T(n)
    ph = 2 * np.pi * np.cumsum(50 + 120 * np.exp(-t * 30)) / SR
    body = np.sin(ph) * np.exp(-t * 6.5)
    click = hp(noise(n), 3000) * np.exp(-t * 400) * .45
    return np.tanh((body + click) * 1.6)


def boom(dur=1.6):
    n = int(dur * SR); t = T(n)
    ph = 2 * np.pi * np.cumsum(44 + 70 * np.exp(-t * 6)) / SR
    s = np.sin(ph) * np.exp(-t * 2.4) + lp(noise(n), 260) * np.exp(-t * 5) * .7
    return np.tanh(s * 1.4)


def crash(dur=1.8):
    n = int(dur * SR); t = T(n)
    return hp(noise(n), 4500) * np.exp(-t * 2.6) * .5 + bp(noise(n), 2000, 7000) * np.exp(-t * 8) * .4


def hat(open_=False):
    n = int((.2 if open_ else .05) * SR); t = T(n)
    return hp(noise(n), 7500, 4) * np.exp(-t * (16 if open_ else 90))


def clap():
    n = int(.3 * SR); t = T(n)
    env = np.exp(-t * 16) * .5
    for d in (0, .008, .017):
        s = int(d * SR); env[s:] += np.exp(-t[:n - s] * 140) * .6
    return bp(noise(n), 900, 3200) * env


def pluck(f, dur=.5, harm=12, decay=4.0):
    n = int(dur * SR); t = T(n); s = np.zeros(n)
    for k in range(1, harm + 1):
        if f * k > SR / 2.2: break
        s += np.sin(2 * np.pi * f * k * t) / k * np.exp(-t * (decay + k * 1.8))
    return s * (1 - np.exp(-t * 800))


def plink(f, dur=.7):
    n = int(dur * SR); t = T(n)
    mod = np.sin(2 * np.pi * f * 2 * t) * 2.2 * np.exp(-t * 18)
    return np.sin(2 * np.pi * f * t + mod) * np.exp(-t * 7) * (1 - np.exp(-t * 2000))


def thud():
    n = int(.18 * SR); t = T(n)
    return np.sin(2 * np.pi * np.cumsum(65 + 90 * np.exp(-t * 40)) / SR) * np.exp(-t * 26)


def tick(f=3200, dur=.03):
    n = int(dur * SR); t = T(n)
    return np.sin(2 * np.pi * f * t) * np.exp(-t * 160)


def pad(notes, dur, cut=1400, rel=.6):
    n = int((dur + rel) * SR); t = T(n); out = np.zeros((n, 2))
    for ch in range(2):
        s = np.zeros(n)
        for m in notes:
            for c in (-8, 0, 8):
                s += saw(midi(m) * 2 ** (c / 1200), t, rng.random())
        out[:, ch] = lp(s, cut) / (len(notes) * 3)
    env = np.minimum(1, t / .2) * np.where(t < dur, 1, np.exp(-(t - dur) * 7))
    return out * env[:, None]


def bassnote(f, dur=.11):
    n = int(dur * SR); t = T(n)
    s = np.sin(2 * np.pi * f * t) * .9 + lp(saw(f, t), 420) * .55 + np.sin(np.pi * f * t) * .15
    return s * (1 - np.exp(-t * 500)) * np.exp(-t * 7)


def stab(notes, dur=.22):
    n = int(dur * SR); t = T(n); s = np.zeros(n)
    for m in notes:
        s += saw(midi(m), t, rng.random()) + saw(midi(m) * 1.004, t, rng.random())
    return lp(s, 3200) / len(notes) * np.exp(-t * 11)


def riser(dur, f0=250, f1=7000):
    n = int(dur * SR); t = T(n)
    return sweep(noise(n), f0, f1) * (t / dur) ** 2.2


def whoosh(dur, f0=400, f1=4000, p0=-.8, p1=.8):
    n = int(dur * SR); t = T(n); u = t / dur
    x = sweep(noise(n), f0, f1) * np.sin(np.pi * u) ** 2
    a = (lerp(p0, p1, u) + 1) * np.pi / 4
    return np.stack([x * np.cos(a), x * np.sin(a)], 1) * np.sqrt(2)


def lerp(a, b, t): return a + (b - a) * t


def uiclick():
    n = int(.04 * SR); t = T(n)
    return hp(noise(n), 2500) * np.exp(-t * 600) * .6 + np.sin(2 * np.pi * 2400 * t) * np.exp(-t * 300) * .5


def glitch(dur=.22):
    n = int(dur * SR); hold = 90
    x = np.repeat(noise(n // hold + 1), hold)[:n]
    x = np.round(x * 3) / 3 * (np.sin(2 * np.pi * 37 * T(n)) > 0)
    return bp(x, 400, 6000) * .8


def pew(f0=1900, f1=520, dur=.14):
    n = int(dur * SR); t = T(n)
    return np.sin(2 * np.pi * np.cumsum(f1 + (f0 - f1) * np.exp(-t * 30)) / SR) * np.exp(-t * 22)


# ------------------------------------------------------------ harmony
FM = [53, 56, 60, 63]; DB = [49, 53, 56, 60]; AB = [51, 55, 56, 60]; EB = [51, 55, 58, 65]; FM9 = [53, 56, 60, 67]
ROOT = {id(FM): 41, id(DB): 37, id(AB): 44, id(EB): 39, id(FM9): 41}
PROG = [FM, FM, DB, AB, EB, FM, DB, FM9]      # one chord per bar (bar 6 splits Db/Eb below)


# ------------------------------------------------------------ the arrangement
# bar 0 — intro: drone, ball bounces, riser into the drop
put(pad(FM, BAR, cut=520), 0, g=.35, bus=music, rev=.4)
for k, m in enumerate([80, 84, 87]):
    ti = (k + 1) * BEAT
    put(plink(midi(m)), ti, g=.32, pan=-.25 + k * .25, rev=.5)
    put(thud(), ti, g=.5 - k * .08)
put(riser(.95), BAR - .95, g=.28, rev=.3)
put(whoosh(.5, 300, 5000), 3 * BEAT, g=.3)
put(crash(.9)[::-1], BAR - .9, g=.35)

# bars 1–6: the groove
kicks = [BAR + i * BEAT for i in range(24)]
for tk in kicks:
    put(kick(), tk, g=.95)
for b in range(1, 7):
    t0 = b * BAR
    for i in range(4):
        tb = t0 + i * BEAT
        put(hat(open_=(i % 2 == 1)), tb + BEAT / 2, g=.15 if i % 2 else .11, pan=.3)
        put(hat(), tb + BEAT * .75, g=.065, pan=-.3)
        if i in (1, 3):
            put(clap(), tb, g=.42, rev=.25)
    chords = [(DB, 0, BAR / 2), (EB, BAR / 2, BAR / 2)] if b == 6 else [(PROG[b], 0, BAR)]
    for ch, off, dur in chords:
        put(pad(ch, dur, cut=1300 + 300 * b), t0 + off, g=.34, bus=music, rev=.3)
        root = midi(ROOT[id(ch)])
        for q in range(int(dur / (BEAT / 4) + .5)):
            if q % 4 == 0: continue            # leave the downbeat to the kick
            put(bassnote(root), t0 + off + q * BEAT / 4, g=.36, bus=music)

# arpeggio with ping-pong dotted-eighth delay (bars 2–6)
arp = np.zeros((N, 2))
pattern = [0, 1, 2, 3, 2, 1, 3, 2]
for b in range(2, 7):
    for q in range(16):
        ch = (DB if q < 8 else EB) if b == 6 else PROG[b]
        m = ch[pattern[q % 8]] + 12
        put(pluck(midi(m), .35, harm=8, decay=9), b * BAR + q * BEAT / 4, g=.15, pan=(-.35 if q % 2 else .35), bus=arp)
d = int(.75 * BEAT * SR)
arp_mono = arp.mean(1)
for k in range(1, 4):                          # echoes alternate left / right
    music[d * k:, k % 2] += arp_mono[:-d * k] * .45 ** k
music += arp
send += arp * .35

# the drop
put(boom(), BAR, g=.6)
put(crash(), BAR, g=.4, rev=.3)

# bar 1 — kinetic type: word ticks, strike swish, letter-roll, the full stop
for i in range(3):
    put(tick(2600 + i * 300), BAR + i * .06, g=.18, pan=-.4 + i * .3)
put(whoosh(.24, 1500, 6000, -.6, .6), BAR + BEAT - .08, g=.25)
for i in range(12):
    put(tick(1800 + i * 160, .025), BAR + 2 * BEAT - .1 + i * .022, g=.12, pan=-.6 + i * .1)
put(plink(midi(77)), BAR + 2 * BEAT + CUT, g=.3, rev=.4)
put(plink(midi(72)), BAR + 3 * BEAT, g=.2, rev=.4)
put(whoosh(.45, 400, 6000, .8, -.8), 2 * BAR - .45, g=.35)

# bar 2 — morphs land on the beat
put(tick(900, .06), 2 * BAR, g=.3)
for k, m in enumerate([72, 77, 80]):
    put(pluck(midi(m), .9, harm=10, decay=3), 2 * BAR + (k + 1) * BEAT + .04, g=.25, rev=.45)
    put(thud(), 2 * BAR + (k + 1) * BEAT + .04, g=.35)
put(riser(.45, 400, 8000), 3 * BAR - .45, g=.3)
put(whoosh(.4, 200, 3000), 3 * BAR - .4, g=.3)

# bar 3 — data sonification: every bar of the chart is a note of F minor pentatonic
penta = [65, 68, 70, 72, 75, 77, 80, 82, 84, 87, 89, 92, 94, 96]
for k, m in enumerate(penta):
    put(pluck(midi(m), .3, harm=6, decay=14), 3 * BAR + .18 + k * .035, g=.13, pan=-.7 + k * .1, rev=.3)
n = int(.72 * SR); tt = T(n)
put(np.sin(2 * np.pi * np.cumsum(300 * 2 ** (tt / .72 * 2.2)) / SR) * np.sin(np.pi * tt / .72) ** 2, 3 * BAR + .5, g=.08, rev=.4)
put(riser(.5, 200, 9000), 4 * BAR - .5, g=.35)
put(crash(.5)[::-1], 4 * BAR - .5, g=.3)

# bar 4 — the globe: impact, then a flight of arcs
put(boom(), 4 * BAR, g=.55)
put(crash(), 4 * BAR, g=.3, rev=.3)
for k in range(10):
    tl = 4 * BAR + .45 + k * .085
    put(pew(), tl, g=.07, pan=-.7 + k * .15, rev=.3)
    put(plink(midi(96 - (k % 4) * 3), .3), tl + .5, g=.06, pan=-.7 + k * .15, rev=.5)
put(whoosh(.5, 300, 6000), 5 * BAR - .5, g=.3)

# bar 5 — particles: swirl, shimmer, detonation
put(whoosh(.95, 200, 3000, -.9, .9), 5 * BAR, g=.4)
for k, m in enumerate([77, 80, 84, 87]):
    put(plink(midi(m), 1.0), 5 * BAR + 2 * BEAT + k * .03, g=.08, pan=-.5 + k * .33, rev=.6)
put(crash(.47)[::-1], 5 * BAR + 3 * BEAT - .47, g=.35)
put(boom(1.2), 5 * BAR + 3 * BEAT, g=.5)
put(hp(noise(int(.6 * SR)), 1200) * np.exp(-T(int(.6 * SR)) * 7), 5 * BAR + 3 * BEAT, g=.25, rev=.3)

# bar 6 — the edit: a stab on every cut, a glitch, a snare build into the portal
stabs = [FM, DB, AB, EB, FM, None, EB, FM]
for k, ch in enumerate(stabs):
    tc = 6 * BAR + k * CUT
    if ch is None:
        put(glitch(), tc, g=.3, rev=.2)
    else:
        put(stab([m + 12 for m in ch]), tc, g=.28, pan=(-.3 if k % 2 else .3), bus=music, rev=.25)
for q in range(8):
    put(clap(), 6 * BAR + 2 * BEAT + q * BEAT / 4, g=.08 + q * .025)
put(riser(.6, 300, 10000), 7 * BAR - .6, g=.35)
put(crash(.6)[::-1], 7 * BAR - .6, g=.35)

# bar 7 — resolve: final hit, the dot lands, the button is clicked
put(kick(), 7 * BAR, g=1.0)
put(boom(2.0), 7 * BAR, g=.65)
put(crash(2.0), 7 * BAR, g=.4, rev=.4)
put(pad(FM9, BAR - .3, cut=2200, rel=.9), 7 * BAR, g=.38, bus=music, rev=.45)
put(bassnote(midi(29), 1.4), 7 * BAR, g=.35, bus=music)
put(plink(midi(89)), 7 * BAR + 2 * BEAT, g=.3, rev=.5)
put(plink(midi(84)), 7 * BAR + 2 * BEAT + CUT, g=.18, rev=.5)
put(uiclick(), 7 * BAR + 3 * BEAT, g=.5)
for k, m in enumerate([77, 80, 84, 91]):
    put(plink(midi(m), 1.2), 7 * BAR + 3 * BEAT + k * .012, g=.12, pan=-.45 + k * .3, rev=.7)

# ------------------------------------------------------------ mix
sc = np.ones(N)
for tk in kicks:
    s = int(tk * SR); n = min(int(.35 * SR), N - s); t = T(n)
    sc[s:s + n] *= 1 - .6 * np.exp(-t / .09)
music *= sc[:, None]

ir_n = int(2.2 * SR); ti = T(ir_n)
ir = np.stack([lp(noise(ir_n), 6000), lp(noise(ir_n), 6000)], 1) * np.exp(-ti / .45)[:, None]
ir[:int(.02 * SR)] = 0
ir /= np.sqrt((ir ** 2).sum(0))
wet = np.stack([fftconvolve(send[:, c], ir[:, c])[:N] for c in range(2)], 1)

mix = drums + music + wet * .5
mix = np.stack([hp(mix[:, c], 28) for c in range(2)], 1)
# master EQ: tuck the sub for small speakers, open up the top
mix = mix - np.stack([lp(mix[:, c], 75) for c in range(2)], 1) * .35 + np.stack([hp(mix[:, c], 3500) for c in range(2)], 1) * .9
mix = np.tanh(mix * 1.1) / np.tanh(1.1)
fade = np.ones(N); fi = int(.01 * SR); fo = int(.3 * SR)
fade[:fi] = np.linspace(0, 1, fi); fade[-fo:] = np.linspace(1, 0, fo) ** 2
mix *= fade[:, None]
import pyloudnorm
mix *= .89 / np.abs(mix).max()
lufs = pyloudnorm.Meter(SR).integrated_loudness(mix)
mix *= min(1.0, 10 ** ((-12 - lufs) / 20))   # master to -12 LUFS, peak stays <= -1 dBFS

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'reel.wav')
wavfile.write(out, SR, (mix * 32767).astype(np.int16))
print(f'wrote {out}  peak {20 * np.log10(np.abs(mix).max()):.1f} dBFS  rms {20 * np.log10(np.sqrt((mix ** 2).mean())):.1f} dBFS')
