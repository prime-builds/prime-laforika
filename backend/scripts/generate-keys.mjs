// Generates a development/test RS256 key pair for signing access tokens.
//
// Output goes to backend/secrets/, which is git-ignored. This script never
// prints key material. CI generates ephemeral keys the same way.
//
// Usage: node scripts/generate-keys.mjs [--force]
import { generateKeyPairSync } from 'node:crypto';
import { mkdirSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const secretsDir = resolve(here, '..', 'secrets');
const privatePath = resolve(secretsDir, 'jwt-private.pem');
const publicPath = resolve(secretsDir, 'jwt-public.pem');

const force = process.argv.includes('--force');

if (!force && existsSync(privatePath) && existsSync(publicPath)) {
  console.log('RS256 key pair already exists; use --force to regenerate.');
  process.exit(0);
}

const { publicKey, privateKey } = generateKeyPairSync('rsa', {
  modulusLength: 2048,
  publicKeyEncoding: { type: 'spki', format: 'pem' },
  privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
});

mkdirSync(secretsDir, { recursive: true });
writeFileSync(privatePath, privateKey, { mode: 0o600 });
writeFileSync(publicPath, publicKey, { mode: 0o644 });

console.log('RS256 key pair written to backend/secrets/ (git-ignored).');
