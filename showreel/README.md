# Thom Bailly — 20-second reel

A 20-second, 1080p60 promo in the visual language of [consulting.thomasbailly.com](https://consulting.thomasbailly.com), cut to "Boardroom Drift".

**Watch:** `showreel.mp4`, or open `index.html` through any static server and click to play it live in the browser.

Every frame is a pure function of time: springs, easings and closed-form paths, with no keyframes. All cues sit on the track's own beat grid (130.2 BPM). The cut runs from 39.208s into the song to its final hit.

## Structure

| Time | Message | What moves |
|------|---------|------------|
| 0.00 | **Experience** | Microsoft, Pinterest, Twitter and Yahoo cut in one per beat, then line up together |
| 2.77 | (transition) | The logos collapse into a blue ball that bounces through the break, squashes into a line, and opens the page on the drop |
| 5.07 | **$300M, revenue restructured** | An odometer rolls to $300M as the bars spring up and the curve draws itself; then the camera pushes into the last data point |
| 8.76 | **5 continents** | The data point becomes a globe; routes fly out of London and the count rolls 1 → 5 as each continent is reached |
| 14.29 | **Hi! I'm Thom Bailly, and I can transform your growth strategy from good to unparalleled.** | The globe collapses into one point, the page irises open, and that point lands as the full stop; the cursor clicks "Let's talk"; the song's final hit rings out |

## Brand

Sampled from the live site: blue `#0073D1`, ink `#030712`, body grey `#6B7280`, white. One stretch tone: sky `#4FB0FF`. Type: Bricolage Grotesque (display, synthetic italic for the blue accents), Inter Tight (button), JetBrains Mono (labels). All fonts are OFL and bundled in `fonts/`.

Company logos come from the CC0 [gilbarbara/logos](https://github.com/gilbarbara/logos) set, recoloured to white (`logos/`). The trademarks belong to their owners and appear here to show past employment.

## Rebuild

```sh
pip install numpy scipy imageio-ffmpeg
python3 audio.py path/to/Boardroom_Drift.mp3     # -> reel.wav (the 20s cut + click and whoosh)
ffmpeg -i reel.wav -c:a aac -b:a 192k reel.m4a    # audio for the live player
npm i -g playwright                               # or point NODE_PATH at an existing install
node render.cjs                                   # -> showreel.mp4 (6-sample motion blur)
node render.cjs --stills=2.5,8.1 --sub=1          # quick PNG checks
```

The full track isn't in the repo, so pass its path to `audio.py`. `render.cjs` accepts `--chrome=<path>` and `--ffmpeg=<path>` when those aren't on `PATH`.
