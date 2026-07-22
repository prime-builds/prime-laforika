import {
  assertPasswordPolicy,
  generateOtpCode,
  generateRefreshToken,
  hashOpaqueSecret,
  normalizeEmail,
  normalizePhone,
  safeEqualHex,
  toLatinDigits,
} from './crypto.util';

describe('crypto util', () => {
  it('converts Persian and Arabic digits', () => {
    expect(toLatinDigits('۰۹۱۲')).toBe('0912');
    expect(toLatinDigits('٠٩١٢')).toBe('0912');
  });

  it('normalizes Iranian national phones to E.164', () => {
    expect(normalizePhone('09121234567')).toBe('+989121234567');
  });

  it('canonicalizes email', () => {
    expect(normalizeEmail('  Foo@Example.COM ')).toBe('foo@example.com');
  });

  it('rejects short passwords', () => {
    expect(() => assertPasswordPolicy('short')).toThrow();
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
