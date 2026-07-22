import {
  assertDedicatedTestDatabase,
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
