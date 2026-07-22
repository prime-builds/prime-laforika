import {
  assertDedicatedTestDatabase,
  destinationRateLimitBucketKey,
  fingerprintDestination,
  fingerprintOrigin,
  parseDatabaseName,
  resolveRequestOrigin,
} from './origin.util';

describe('origin.util', () => {
  it('fingerprints origins without retaining raw IP', () => {
    const a = fingerprintOrigin('203.0.113.10', 'pepper');
    const b = fingerprintOrigin('203.0.113.10', 'pepper');
    const c = fingerprintOrigin('203.0.113.11', 'pepper');
    expect(a).toBe(b);
    expect(a).not.toBe(c);
    expect(a).not.toContain('203.0.113');
  });

  describe('fingerprintDestination', () => {
    const base = {
      destinationType: 'EMAIL',
      destinationNormalized: 'user@example.com',
      purpose: 'EMAIL_VERIFY',
      pepper: 'rate-limit-pepper',
    };

    it('same inputs produce the same hash', () => {
      expect(fingerprintDestination(base)).toBe(fingerprintDestination(base));
    });

    it('different destinations differ', () => {
      const other = {
        ...base,
        destinationNormalized: 'other@example.com',
      };
      expect(fingerprintDestination(base)).not.toBe(
        fingerprintDestination(other),
      );
    });

    it('phone vs email namespaces differ for the same normalized string', () => {
      const shared = 'shared-normalized-value';
      const emailFp = fingerprintDestination({
        ...base,
        destinationType: 'EMAIL',
        destinationNormalized: shared,
      });
      const phoneFp = fingerprintDestination({
        ...base,
        destinationType: 'PHONE',
        destinationNormalized: shared,
      });
      expect(emailFp).not.toBe(phoneFp);
    });

    it('origin vs destination namespaces differ for the same raw value', () => {
      const raw = 'user@example.com';
      const pepper = 'shared-pepper';
      const originFp = fingerprintOrigin(raw, pepper);
      const destFp = fingerprintDestination({
        destinationType: 'EMAIL',
        destinationNormalized: raw,
        purpose: 'EMAIL_VERIFY',
        pepper,
      });
      expect(originFp).not.toBe(destFp);
    });

    it('pepper change alters fingerprint', () => {
      expect(fingerprintDestination(base)).not.toBe(
        fingerprintDestination({ ...base, pepper: 'other-pepper' }),
      );
    });

    it('destinationRateLimitBucketKey never contains raw email/phone substrings', () => {
      const emailKey = destinationRateLimitBucketKey(base);
      expect(emailKey).not.toContain('example.com');
      expect(emailKey).not.toContain('user@');
      expect(emailKey).not.toContain(base.destinationNormalized);

      const phoneKey = destinationRateLimitBucketKey({
        destinationType: 'PHONE',
        destinationNormalized: '+989121234567',
        purpose: 'PHONE_SIGN_IN',
        pepper: base.pepper,
      });
      expect(phoneKey).not.toContain('+989');
      expect(phoneKey).not.toContain('989121234567');
      expect(phoneKey).toMatch(
        /^challenge:dest:v1:PHONE:[a-f0-9]+:PHONE_SIGN_IN$/,
      );
    });
  });

  it('parses database name from URL', () => {
    expect(
      parseDatabaseName(
        'postgresql://postgres:pw@127.0.0.1:5432/laforika_test',
      ),
    ).toBe('laforika_test');
  });

  it('uses socket IP unless forwarded trust is enabled', () => {
    const req = {
      ip: '10.0.0.1',
      headers: { 'x-forwarded-for': '203.0.113.9, 10.0.0.1' },
    };
    expect(resolveRequestOrigin(req, false)).toBe('10.0.0.1');
    expect(resolveRequestOrigin(req, true)).toBe('203.0.113.9');
  });

  describe('assertDedicatedTestDatabase', () => {
    const good = {
      APP_ENVIRONMENT: 'test',
      DATABASE_URL: 'postgresql://postgres:pw@127.0.0.1:5432/laforika_test',
      TEST_DATABASE_NAME: 'laforika_test',
    };

    it('accepts matching dedicated test database', () => {
      expect(assertDedicatedTestDatabase(good)).toEqual({
        databaseName: 'laforika_test',
      });
    });

    it('refuses non-test APP_ENVIRONMENT', () => {
      expect(() =>
        assertDedicatedTestDatabase({ ...good, APP_ENVIRONMENT: 'dev' }),
      ).toThrow(/APP_ENVIRONMENT=test/);
    });

    it('refuses missing or non-_test TEST_DATABASE_NAME', () => {
      expect(() =>
        assertDedicatedTestDatabase({
          ...good,
          TEST_DATABASE_NAME: undefined,
        }),
      ).toThrow(/TEST_DATABASE_NAME/);
      expect(() =>
        assertDedicatedTestDatabase({
          ...good,
          TEST_DATABASE_NAME: 'laforika_dev',
        }),
      ).toThrow(/_test/);
    });

    it('refuses mismatched DATABASE_URL database name', () => {
      expect(() =>
        assertDedicatedTestDatabase({
          ...good,
          DATABASE_URL: 'postgresql://postgres:pw@127.0.0.1:5432/laforika_dev',
        }),
      ).toThrow(/does not match/);
    });

    it('refuses missing DATABASE_URL', () => {
      expect(() =>
        assertDedicatedTestDatabase({
          ...good,
          DATABASE_URL: undefined,
        }),
      ).toThrow(/DATABASE_URL/);
    });
  });
});
