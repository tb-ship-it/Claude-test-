// Frame-accurate renderer: drives index.html in headless Chromium and pipes
// every frame (with sub-frame motion blur) into ffmpeg.
//
//   node render.cjs                         -> showreel.mp4 (1080p60, motion blur, audio)
//   node render.cjs --stills=0.5,2.3 --out=stills   -> PNG stills for review
//   node render.cjs --sub=1 --video=draft.mp4        -> fast draft without motion blur
//
// Needs Playwright (NODE_PATH to a global install is fine) and an ffmpeg with libx264.
const { chromium } = require('playwright');
const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const ROOT = __dirname;
const arg = (k, d) => { const a = process.argv.find(s => s.startsWith(`--${k}=`)); return a ? a.split('=').slice(1).join('=') : d; };
const SUB = +arg('sub', 6);
const FFMPEG = arg('ffmpeg', process.env.FFMPEG || 'ffmpeg');
const VIDEO = path.resolve(ROOT, arg('video', 'showreel.mp4'));
const AUDIO = path.resolve(ROOT, arg('audio', 'reel.wav'));
const STILLS = arg('stills', null);
const OUT = path.resolve(ROOT, arg('out', 'stills'));
const CHROME = arg('chrome', process.env.CHROME || undefined);

const MIME = { '.html': 'text/html', '.woff2': 'font/woff2', '.svg': 'image/svg+xml', '.m4a': 'audio/mp4', '.wav': 'audio/wav' };
const server = http.createServer((req, res) => {
  const p = path.join(ROOT, decodeURIComponent(req.url.split('?')[0]));
  if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { 'Content-Type': MIME[path.extname(p)] || 'application/octet-stream' });
  fs.createReadStream(p).pipe(res);
});

(async () => {
  await new Promise(r => server.listen(0, '127.0.0.1', r));
  const url = `http://127.0.0.1:${server.address().port}/index.html?render`;
  const browser = await chromium.launch({ executablePath: CHROME, args: ['--disable-gpu', '--force-color-profile=srgb'] });
  const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
  page.on('pageerror', e => { console.error('page error:', e); process.exit(1); });
  await page.goto(url);
  await page.evaluate(() => window.reel.ready);
  const { FPS, DUR } = await page.evaluate(() => ({ FPS: reel.FPS, DUR: reel.DUR }));
  const grab = async (f, sub) => {
    const data = await page.evaluate(([f, sub]) => { reel.renderFrame(f, sub); return reel.snap(); }, [f, sub]);
    return Buffer.from(data.split(',')[1], 'base64');
  };

  if (STILLS) {
    fs.mkdirSync(OUT, { recursive: true });
    for (const s of STILLS.split(',')) {
      const f = Math.round(+s * FPS);
      fs.writeFileSync(path.join(OUT, `f${String(f).padStart(4, '0')}.png`), await grab(f, SUB));
    }
    console.log(`wrote ${STILLS.split(',').length} stills to ${OUT}`);
  } else {
    const total = Math.round(DUR * FPS);
    const ff = spawn(FFMPEG, [
      '-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(FPS), '-c:v', 'png', '-i', '-',
      ...(fs.existsSync(AUDIO) ? ['-i', AUDIO] : []),
      '-vf', 'scale=out_color_matrix=bt709:out_range=tv,format=yuv420p,noise=c0s=3:allf=t',
      '-c:v', 'libx264', '-preset', 'slow', '-crf', '17', '-profile:v', 'high', '-tune', 'animation',
      '-colorspace', 'bt709', '-color_primaries', 'bt709', '-color_trc', 'bt709',
      ...(fs.existsSync(AUDIO) ? ['-c:a', 'aac', '-b:a', '256k', '-shortest'] : []),
      '-movflags', '+faststart', VIDEO,
    ], { stdio: ['pipe', 'inherit', 'inherit'] });
    const t0 = Date.now();
    for (let f = 0; f < total; f++) {
      const png = await grab(f, SUB);
      if (!ff.stdin.write(png)) await new Promise(r => ff.stdin.once('drain', r));
      if (f % 60 === 0) process.stdout.write(`\rframe ${f}/${total}  ${((Date.now() - t0) / 1000).toFixed(0)}s`);
    }
    ff.stdin.end();
    await new Promise((res, rej) => ff.on('close', c => c === 0 ? res() : rej(new Error('ffmpeg exit ' + c))));
    console.log(`\nwrote ${VIDEO} in ${((Date.now() - t0) / 1000).toFixed(0)}s`);
  }
  await browser.close();
  server.close();
})().catch(e => { console.error(e); process.exit(1); });
