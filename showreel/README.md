# Claude — Motion Reel 2026

A 15-second, 1080p60 motion-design showreel, styled after [consulting.thomasbailly.com](https://consulting.thomasbailly.com).

**Watch:** `showreel.mp4`, or open `index.html` through any static server and click to play it live in the browser.

Every frame is a pure function of time. No keyframes, no timeline, no plugins: springs, easings and closed-form paths on a 128 BPM grid. 8 bars of 1.875s is exactly 15.000s, and the score is synthesised on the same grid, so every cut, hit and bounce lands on the beat.

## Chapters

| # | Time | Chapter | Technique on show |
|---|------|---------|-------------------|
| 01 | 0.00 | Squash & stretch | Physically timed bounces, onion skins, impact rings; the ball stretches into a line that opens the page |
| 02 | 1.88 | Kinetic type | The site's own hero line. Variable-weight reflow (200 to 800), masked reveals, a strike-through, and a full stop that is a bouncing ball |
| 03 | 3.75 | Shape morph | 240-point path morphs with time-lagged echoes, selection handles and a live graph editor |
| 04 | 5.63 | Data in motion | Spring-loaded bars, self-drawing curve, odometer counter, then a push into the data point |
| 05 | 7.50 | 3D + arcs | The data point becomes a 5,200-dot globe (real land mask) with great-circle routes out of London |
| 06 | 9.38 | Particles | The globe's own dots fly into the word GROWTH, then detonate on the beat |
| 07 | 11.25 | The edit | Eight cuts on eighth notes: tile flips, marquees, glitch, squash, echo stacks |
| 08 | 13.13 | Resolve | A match cut through the O of "YOUR MOVE" into an end card in the site's hero language, with a CTA click |

## Brand

Sampled from the live site: blue `#0073D1`, ink `#030712`, body grey `#6B7280`, white, tile grey `#EFEFEF`. Stretch tones: sky `#4FB0FF` and panel navy `#0D1526`. Type: Bricolage Grotesque (display, synthetic italic for the blue accents), Inter Tight (body), JetBrains Mono (HUD). All fonts are OFL and bundled in `fonts/`.

## Rebuild

```sh
pip install numpy scipy pyloudnorm imageio-ffmpeg
python3 audio.py                     # -> reel.wav (score, mastered to -12 LUFS)
ffmpeg -i reel.wav -c:a aac -b:a 192k reel.m4a   # audio for the live player
npm i -g playwright                  # or point NODE_PATH at an existing install
node render.cjs                      # -> showreel.mp4 (6-sample motion blur)
node render.cjs --stills=2.5,8.6 --sub=1   # quick PNG checks
```

`render.cjs` accepts `--chrome=<path>` and `--ffmpeg=<path>` when those aren't on `PATH`.
