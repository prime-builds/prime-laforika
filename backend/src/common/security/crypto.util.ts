import { createHash, createHmac, randomBytes, randomUUID, timingSafeEqual } from 'crypto';
import { readFileSync } from 'fs';
import * as argon2 from 'argon2';
import {
  parsePhoneNumberFromString,
  type CountryCode,
} from 'libphonenumber-js';
import { AppError } from '../errors/app-error';

const PERSIAN = '۰۱۲۳۴۵۶۷۸۹';
const ARABIC = '٠١٢٣٤٥٦٧٨٩';

export function toLatinDigits(input: string): string {
  return [...input]
    .map((ch) => {
      const p = PERSIAN.indexOf(ch);
      if (p >= 0) return String(p);
      const a = ARABIC.indexOf(ch);
      if (a >= 0) return String(a);
      return ch;
    })
    .join('');
}

export function normalizePhone(input: string, defaultCountry: CountryCode = 'IR'): string {
  const latin = toLatinDigits(input).trim();
  const parsed = parsePhoneNumberFromString(latin, defaultCountry);
  if (!parsed || !parsed.isValid()) {
    throw new AppError('VALIDATION_ERROR', 400, ['phone']);
  }
  return parsed.format('E.164');
}

export function normalizeEmail(input: string): string {
  return input.trim().normalize('NFC').toLowerCase();
}

export function maskPhone(e164: string): string {
  if (e164.length < 6) return '***';
  return `${e164.slice(0, 4)}****${e164.slice(-2)}`;
}

export function maskEmail(email: string): string {
  const [local, domain] = email.split('@');
  if (!domain) return '***';
  const visible = local.slice(0, Math.min(2, local.length));
  return `${visible}***@${domain}`;
}

const COMMON_PASSWORDS = new Set(
  [
    'password',
    'password123456',
    '123456789012345',
    'qwertyuiopasdfg',
    'iloveyouiloveyou',
    'adminadminadmin',
    'letmeinletmein1',
    'welcomewelcome1',
    'changemechangeme',
    'footballfootball',
  ].map((p) => p.toLowerCase()),
);

export function assertPasswordPolicy(password: string): void {
  if (password.length < 15 || password.length > 128) {
    throw new AppError('VALIDATION_ERROR', 400, ['password']);
  }
  if (COMMON_PASSWORDS.has(password.toLowerCase())) {
    throw new AppError('VALIDATION_ERROR', 400, ['password']);
  }
}

export async function hashPassword(
  password: string,
  pepper: string,
): Promise<string> {
  assertPasswordPolicy(password);
  return argon2.hash(`${password}${pepper}`, {
    type: argon2.argon2id,
    memoryCost: 19456,
    timeCost: 2,
    parallelism: 1,
  });
}

export async function verifyPassword(
  hash: string,
  password: string,
  pepper: string,
): Promise<{ ok: boolean; needsRehash: boolean }> {
  const ok = await argon2.verify(hash, `${password}${pepper}`);
  return { ok, needsRehash: ok && argon2.needsRehash(hash) };
}

export function hashOpaqueSecret(value: string, pepper: string): string {
  return createHmac('sha256', pepper).update(value).digest('hex');
}

export function generateOtpCode(): string {
  const n = randomBytes(4).readUInt32BE(0) % 1_000_000;
  return n.toString().padStart(6, '0');
}

export function generateRefreshToken(): string {
  return randomBytes(32).toString('base64url');
}

export function safeEqualHex(a: string, b: string): boolean {
  const ba = Buffer.from(a);
  const bb = Buffer.from(b);
  if (ba.length !== bb.length) return false;
  return timingSafeEqual(ba, bb);
}

export function sha256(value: string): string {
  return createHash('sha256').update(value).digest('hex');
}

export function loadPem(path: string): string {
  return readFileSync(path, 'utf8');
}

export function randomUuid(): string {
  return randomUUID();
}
