# Thom Bailly — 15-second reel

A 15-second, 1080p60 promo in the visual language of [consulting.thomasbailly.com](https://consulting.thomasbailly.com), cut to "Boardroom Drift".

**Watch:** `showreel.mp4`, or open `index.html` through any static server and click to play it live in the browser.

Every frame is a pure function of time: springs, easings and closed-form paths, with no keyframes. All cues sit on the track's own beat grid (130.2 BPM). The cut starts 42.434s into the song, one bar before a drop.

## Structure

| Time | Message | What moves |
|------|---------|------------|
| 0.00 | (intro) | A blue ball bounces on the break's beats, squashes into a line on the build, and the line opens the page on the drop |
| 1.84 | **$300M, revenue restructured** | An odometer rolls to $300M as the bars spring up and the curve draws itself; then the camera pushes into the last data point |
| 5.53 | **5 continents** | The data point becomes a globe; routes fly out of London and the count rolls 1 → 5 as each continent is reached |
| 10.14 | **Hi! I'm Thom Bailly, and I can transform your growth strategy from good to unparalleled.** | The globe collapses into one point, the page irises open, and that point lands as the full stop; the cursor clicks "Let's talk" |

## Brand

Sampled from the live site: blue `#0073D1`, ink `#030712`, body grey `#6B7280`, white. One stretch tone: sky `#4FB0FF`. Type: Bricolage Grotesque (display, synthetic italic for the blue accents), Inter Tight (button), JetBrains Mono (labels). All fonts are OFL and bundled in `fonts/`.

## Rebuild

```sh
pip install numpy scipy imageio-ffmpeg
python3 audio.py path/to/Boardroom_Drift.mp3     # -> reel.wav (the 15s cut + click and whoosh)
ffmpeg -i reel.wav -c:a aac -b:a 192k reel.m4a    # audio for the live player
npm i -g playwright                               # or point NODE_PATH at an existing install
node render.cjs                                   # -> showreel.mp4 (6-sample motion blur)
node render.cjs --stills=2.5,8.1 --sub=1          # quick PNG checks
```

The full track isn't in the repo, so pass its path to `audio.py`. `render.cjs` accepts `--chrome=<path>` and `--ffmpeg=<path>` when those aren't on `PATH`.
