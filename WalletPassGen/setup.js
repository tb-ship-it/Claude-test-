/**
 * Quick check: verifies the certs directory exists and lists
 * which certificate files are present/missing.
 *
 * Run: node setup.js
 */
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const CERTS_DIR = path.join(__dirname, 'certs');
const REQUIRED = ['wwdr.pem', 'signerCert.pem', 'signerKey.pem'];

console.log('\n=== Wallet Pass Generator — Setup Check ===\n');

if (!fs.existsSync(CERTS_DIR)) {
  fs.mkdirSync(CERTS_DIR);
  console.log('Created certs/ directory.\n');
}

let allGood = true;
for (const f of REQUIRED) {
  const exists = fs.existsSync(path.join(CERTS_DIR, f));
  console.log(`  ${exists ? '✓' : '✗'} certs/${f}`);
  if (!exists) allGood = false;
}

if (allGood) {
  console.log('\nAll certificates found. Run: npm start\n');
} else {
  console.log(`
Missing certificates. To set them up:

1. Log in to developer.apple.com → Certificates, Identifiers & Profiles
2. Create a Pass Type ID (Identifiers → + → Pass Type IDs)
3. Create a Certificate for that Pass Type ID
4. Download Certificates.cer, then in Keychain Access:
   - Double-click Certificates.cer to import it
   - Right-click the private key → Export → save as Certificates.p12

5. Run these commands from this directory:

   openssl x509 -inform DER -in ~/Downloads/Certificates.cer -out certs/signerCert.pem
   openssl pkcs12 -in ~/Downloads/Certificates.p12 -nocerts -nodes -out certs/signerKey.pem

6. Download the Apple WWDR G4 CA:

   curl -o /tmp/wwdr.cer https://www.apple.com/certificateauthority/AppleWWDRCAG4.cer
   openssl x509 -inform DER -in /tmp/wwdr.cer -out certs/wwdr.pem

7. Run: npm start
`);
}
