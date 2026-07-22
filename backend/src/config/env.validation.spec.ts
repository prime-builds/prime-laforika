import 'reflect-metadata';
import { validateEnv } from './env.validation';

function baseConfig(
  overrides: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    APP_ENVIRONMENT: 'test',
    PORT: 3000,
    DATABASE_URL: 'postgresql://postgres:postgres@127.0.0.1:5432/laforika_test',
    JWT_ISSUER: 'laforika-test',
    JWT_AUDIENCE: 'laforika-clients',
    JWT_ACTIVE_KID: 'test-kid',
    JWT_PRIVATE_KEY_PATH: './keys/private.pem',
    JWT_PUBLIC_KEY_PATH: './keys/public.pem',
    REFRESH_TOKEN_PEPPER: 'refresh-pepper-for-tests-only',
    OTP_CODE_PEPPER: 'otp-pepper-for-tests-only-xx',
    PASSWORD_PEPPER: 'password-pepper-for-tests-only',
    RATE_LIMIT_PEPPER: 'rate-limit-pepper-for-tests-only',
    TRUST_FORWARDED_ORIGIN: false,
    FIXTURE_DELIVERY_ENABLED: true,
    DELIVERY_MODE: 'fixture',
    FIXTURE_INBOX_KEY: 'fixture-inbox-key-for-tests',
    CORS_ORIGINS: '*',
    ...overrides,
  };
}

describe('validateEnv', () => {
  it('allows fixture delivery in test', () => {
    expect(() => validateEnv(baseConfig())).not.toThrow();
  });

  it('defaults DELIVERY_MODE to fixture when fixture delivery is enabled', () => {
    const result = validateEnv(
      baseConfig({
        DELIVERY_MODE: undefined,
        FIXTURE_DELIVERY_ENABLED: true,
      }),
    );
    expect(result.DELIVERY_MODE).toBe('fixture');
  });

  it('defaults DELIVERY_MODE to unavailable when fixture delivery is disabled', () => {
    const result = validateEnv(
      baseConfig({
        DELIVERY_MODE: undefined,
        FIXTURE_DELIVERY_ENABLED: false,
      }),
    );
    expect(result.DELIVERY_MODE).toBe('unavailable');
  });

  it('rejects fixture delivery when APP_ENVIRONMENT is staging', () => {
    expect(() =>
      validateEnv(
        baseConfig({
          APP_ENVIRONMENT: 'staging',
          FIXTURE_DELIVERY_ENABLED: true,
          DELIVERY_MODE: 'fixture',
        }),
      ),
    ).toThrow('Fixture delivery is not allowed outside dev/test');
  });

  it('allows staging when fixture delivery is disabled and mode is unavailable', () => {
    expect(() =>
      validateEnv(
        baseConfig({
          APP_ENVIRONMENT: 'staging',
          FIXTURE_DELIVERY_ENABLED: false,
          DELIVERY_MODE: 'unavailable',
        }),
      ),
    ).not.toThrow();
  });

  it('rejects staging when DELIVERY_MODE is fixture', () => {
    expect(() =>
      validateEnv(
        baseConfig({
          APP_ENVIRONMENT: 'staging',
          FIXTURE_DELIVERY_ENABLED: false,
          DELIVERY_MODE: 'fixture',
        }),
      ),
    ).toThrow(/DELIVERY_MODE=fixture/);
  });

  it('defaults TRUST_FORWARDED_ORIGIN to false', () => {
    const result = validateEnv(
      baseConfig({ TRUST_FORWARDED_ORIGIN: undefined }),
    );
    expect(result.TRUST_FORWARDED_ORIGIN).toBe(false);
  });
});
