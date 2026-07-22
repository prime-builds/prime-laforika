import {
  assertPasswordPolicy,
  generateOtpCode,
  generateRefreshToken,
  hashOpaqueSecret,
  hashPassword,
  maskEmail,
  maskPhone,
  normalizeEmail,
  normalizePhone,
  safeEqualHex,
  toLatinDigits,
  verifyPassword,
} from './crypto.util';

describe('crypto util', () => {
  it('converts Persian and Arabic digits', () => {
    expect(toLatinDigits('۰۹۱۲')).toBe('0912');
    expect(toLatinDigits('٠٩١٢')).toBe('0912');
  });

  it('normalizes Iranian national phones to E.164', () => {
    expect(normalizePhone('09121234567')).toBe('+989121234567');
    expect(normalizePhone('۰۹۱۲۱۲۳۴۵۶۷')).toBe('+989121234567');
  });

  it('canonicalizes email', () => {
    expect(normalizeEmail('  Foo@Example.COM ')).toBe('foo@example.com');
  });

  it('masks phone and email for display', () => {
    expect(maskPhone('+989121234567')).toBe('+989****67');
    expect(maskEmail('user@example.com')).toBe('us***@example.com');
  });

  it('rejects short and common passwords', () => {
    expect(() => assertPasswordPolicy('short')).toThrow();
    expect(() => assertPasswordPolicy('password123456')).toThrow();
  });

  it('hashes and verifies passwords with Argon2id', async () => {
    const password = 'correct-horse-battery';
    const pepper = 'unit-test-pepper';
    const hash = await hashPassword(password, pepper);
    expect(hash.startsWith('$argon2id$')).toBe(true);
    const ok = await verifyPassword(hash, password, pepper);
    expect(ok.ok).toBe(true);
    const bad = await verifyPassword(hash, 'wrong-password-xxxx', pepper);
    expect(bad.ok).toBe(false);
  });

  it('generates otp and refresh entropy', () => {
    expect(generateOtpCode()).toMatch(/^\d{6}$/);
    expect(generateRefreshToken().length).toBeGreaterThanOrEqual(40);
  });

  it('hashes and compares opaques safely', () => {
    const hash = hashOpaqueSecret('abc', 'pepper');
    expect(safeEqualHex(hash, hashOpaqueSecret('abc', 'pepper'))).toBe(true);
    expect(safeEqualHex(hash, hashOpaqueSecret('abd', 'pepper'))).toBe(false);
  });
});
