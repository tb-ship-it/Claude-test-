const express = require('express');
const multer = require('multer');
const sharp = require('sharp');
const { PKPass } = require('passkit-generator');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const CERTS_DIR = path.join(__dirname, 'certs');
const MODEL_DIR = path.join(__dirname, 'pass-model');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 20 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) cb(null, true);
    else cb(new Error('Only image files are allowed'));
  }
});

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

app.get('/certs-status', (req, res) => {
  const required = ['wwdr.pem', 'signerCert.pem', 'signerKey.pem'];
  const status = {};
  for (const f of required) {
    status[f] = fs.existsSync(path.join(CERTS_DIR, f));
  }
  res.json(status);
});

app.post('/generate', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No image uploaded' });

    const {
      passTypeIdentifier,
      teamIdentifier,
      description = 'My Pass',
      organizationName = 'My Organization',
      backgroundColor = 'rgb(255,255,255)',
      foregroundColor = 'rgb(0,0,0)',
      labelColor = 'rgb(100,100,100)',
      passphrase = ''
    } = req.body;

    if (!passTypeIdentifier || !teamIdentifier) {
      return res.status(400).json({ error: 'Pass Type Identifier and Team Identifier are required' });
    }

    const certFiles = ['wwdr.pem', 'signerCert.pem', 'signerKey.pem'];
    for (const f of certFiles) {
      if (!fs.existsSync(path.join(CERTS_DIR, f))) {
        return res.status(500).json({ error: `Missing certificate: ${f}. See setup instructions.` });
      }
    }

    // Convert image → 3-scale PNGs for background (540x660) and icon (87x87)
    const bgBuffer = await sharp(req.file.buffer)
      .resize(540, 660, { fit: 'cover', position: 'centre' })
      .png()
      .toBuffer();

    const iconBuffer = await sharp(req.file.buffer)
      .resize(87, 87, { fit: 'cover', position: 'centre' })
      .png()
      .toBuffer();

    const icon2xBuffer = await sharp(req.file.buffer)
      .resize(174, 174, { fit: 'cover', position: 'centre' })
      .png()
      .toBuffer();

    const certificates = {
      wwdr: fs.readFileSync(path.join(CERTS_DIR, 'wwdr.pem')),
      signerCert: fs.readFileSync(path.join(CERTS_DIR, 'signerCert.pem')),
      signerKey: fs.readFileSync(path.join(CERTS_DIR, 'signerKey.pem')),
    };
    if (passphrase) certificates.signerKeyPassphrase = passphrase;

    const pass = await PKPass.from(
      { model: MODEL_DIR, certificates },
      {
        serialNumber: uuidv4(),
        description,
        organizationName,
        passTypeIdentifier,
        teamIdentifier,
        backgroundColor,
        foregroundColor,
        labelColor
      }
    );

    // Background image fills the entire pass card
    pass.addBuffer('background.png', bgBuffer);
    pass.addBuffer('background@2x.png', bgBuffer);
    pass.addBuffer('background@3x.png', bgBuffer);

    // Icon is required by Apple
    pass.addBuffer('icon.png', iconBuffer);
    pass.addBuffer('icon@2x.png', icon2xBuffer);

    const pkpassBuffer = pass.getAsBuffer();

    res.set({
      'Content-Type': 'application/vnd.apple.pkpass',
      'Content-Disposition': `attachment; filename="${description.replace(/[^a-z0-9]/gi, '_')}.pkpass"`
    });
    res.send(pkpassBuffer);

  } catch (err) {
    console.error('Pass generation error:', err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Wallet Pass Generator running at http://localhost:${PORT}`);
  console.log(`Put your Apple certificates in: ${CERTS_DIR}`);
});
