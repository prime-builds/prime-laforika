import { readFileSync } from 'fs';
import { resolve } from 'path';

describe('phone_only_auth migration SQL', () => {
  const historicalVerifiedEmail = readFileSync(
    resolve(
      __dirname,
      '../../../prisma/migrations/20260722183000_verified_email_and_drop_fixture_inbox/migration.sql',
    ),
    'utf8',
  );

  const phoneOnly = readFileSync(
    resolve(
      __dirname,
      '../../../prisma/migrations/20260725120000_phone_only_auth/migration.sql',
    ),
    'utf8',
  );

  it('keeps historical verified-email migration unchanged in intent', () => {
    expect(historicalVerifiedEmail).toContain('email_verified_at');
    expect(historicalVerifiedEmail).not.toMatch(
      /UPDATE\s+"users"[\s\S]*?"email_verified_at"\s*=\s*"created_at"/i,
    );
  });

  it('guards against orphan accounts before dropping password credentials', () => {
    expect(phoneOnly).toMatch(/phone_e164 IS NULL/i);
    expect(phoneOnly).toMatch(/M03_WP03 phone-only migration blocked/i);
    const guardIndex = phoneOnly.indexOf('phone_e164 IS NULL');
    const dropPasswordIndex = phoneOnly.indexOf(
      'DROP COLUMN IF EXISTS password_hash',
    );
    const notNullIndex = phoneOnly.indexOf(
      'ALTER COLUMN phone_e164 SET NOT NULL',
    );
    expect(guardIndex).toBeGreaterThanOrEqual(0);
    expect(dropPasswordIndex).toBeGreaterThan(guardIndex);
    expect(notNullIndex).toBeGreaterThan(guardIndex);
  });

  it('removes password-bearing structures and narrows challenge purpose', () => {
    expect(phoneOnly).toMatch(/DROP COLUMN IF EXISTS password_hash/i);
    expect(phoneOnly).toMatch(/DROP COLUMN IF EXISTS pending_password_hash/i);
    expect(phoneOnly).toMatch(/PHONE_SIGN_IN/);
    expect(phoneOnly).toMatch(/ChallengePurpose_new/);
  });
});
