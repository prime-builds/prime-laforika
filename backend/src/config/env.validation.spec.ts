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
    FIXTURE_DELIVERY_ENABLED: true,
    FIXTURE_INBOX_KEY: 'fixture-inbox-key-for-tests',
    CORS_ORIGINS: '*',
    ...overrides,
  };
}

describe('validateEnv', () => {
  it('allows fixture delivery in test', () => {
    expect(() => validateEnv(baseConfig())).not.toThrow();
  });

  it('rejects fixture delivery when APP_ENVIRONMENT is staging', () => {
    expect(() =>
      validateEnv(
        baseConfig({
          APP_ENVIRONMENT: 'staging',
          FIXTURE_DELIVERY_ENABLED: true,
        }),
      ),
    ).toThrow('Fixture delivery is not allowed outside dev/test');
  });

  it('allows staging when fixture delivery is disabled', () => {
    expect(() =>
      validateEnv(
        baseConfig({
          APP_ENVIRONMENT: 'staging',
          FIXTURE_DELIVERY_ENABLED: false,
        }),
      ),
    ).not.toThrow();
  });
});
