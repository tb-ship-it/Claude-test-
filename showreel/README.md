# Thom Bailly — 20-second reel

A 20-second, 1080p60 promo in the visual language of [consulting.thomasbailly.com](https://consulting.thomasbailly.com), cut to "Boardroom Drift".

**Watch:** `showreel.mp4`, or open `index.html` through any static server and click to play it live in the browser.

Every frame is a pure function of time: springs, easings and closed-form paths, with no keyframes. All cues sit on the track's own beat grid (130.2 BPM). The cut runs from 40.591s into the song, one bar before its last break, through its final hit.

## Structure

| Time | Section | What moves |
|------|---------|------------|
| 0.00 | **Hi! I'm Thom Bailly, and I do…** | The name rises in; the three dots land on the beat, and the last one swells into the next page |
| 2.30 | **Three areas** | Three beats each, title filling the width plus one benefit: Commercial Transformation ("+30% revenue. Same team."), European Market Expansion ("Europe, 18 months faster."), Enterprise Negotiation Training ("Bigger deals. Protected margins.") |
| 6.45 | **Credentials** | One card: Microsoft, Pinterest, Twitter and Yahoo land one per beat |
| 8.76 | **$300M, revenue restructured** | The odometer rolls to $300M as the bars spring up and the curve draws itself; the camera pushes into the last data point |
| 12.44 | **5 continents** | The data point becomes a globe; routes fly out of London and the count rolls 1 → 5 |
| 15.21 | **Taking your growth strategy from good to unparalleled.** | The globe collapses, the page irises open, and the ball lands as the full stop on the song's final hit; "Let's talk" follows |

## Brand

Sampled from the live site: blue `#0073D1`, ink `#030712`, body grey `#6B7280`, white. One stretch tone: sky `#4FB0FF`. Type: Bricolage Grotesque (display, synthetic italic for the blue accents), Inter Tight (button), JetBrains Mono (labels). All fonts are OFL and bundled in `fonts/`.

Company logos come from the CC0 [gilbarbara/logos](https://github.com/gilbarbara/logos) set, recoloured to white (`logos/`). The trademarks belong to their owners and appear here to show past employment.

## Rebuild

```sh
pip install numpy scipy imageio-ffmpeg
python3 audio.py path/to/Boardroom_Drift.mp3     # -> reel.wav (the 20s cut + one whoosh)
ffmpeg -i reel.wav -c:a aac -b:a 192k reel.m4a    # audio for the live player
npm i -g playwright                               # or point NODE_PATH at an existing install
node render.cjs                                   # -> showreel.mp4 (6-sample motion blur)
node render.cjs --stills=2.5,8.1 --sub=1          # quick PNG checks
```

The full track isn't in the repo, so pass its path to `audio.py`. `render.cjs` accepts `--chrome=<path>` and `--ffmpeg=<path>` when those aren't on `PATH`.
