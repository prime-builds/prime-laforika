import { plainToInstance } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsString,
  Max,
  Min,
  validateSync,
} from 'class-validator';

export type DeliveryMode = 'fixture' | 'unavailable';

export class EnvironmentVariables {
  @IsString()
  @IsNotEmpty()
  APP_ENVIRONMENT!: string;

  @IsInt()
  @Min(1)
  @Max(65535)
  PORT!: number;

  @IsString()
  @IsNotEmpty()
  DATABASE_URL!: string;

  @IsString()
  @IsNotEmpty()
  JWT_ISSUER!: string;

  @IsString()
  @IsNotEmpty()
  JWT_AUDIENCE!: string;

  @IsString()
  @IsNotEmpty()
  JWT_ACTIVE_KID!: string;

  @IsString()
  @IsNotEmpty()
  JWT_PRIVATE_KEY_PATH!: string;

  @IsString()
  @IsNotEmpty()
  JWT_PUBLIC_KEY_PATH!: string;

  @IsString()
  @IsNotEmpty()
  REFRESH_TOKEN_PEPPER!: string;

  @IsString()
  @IsNotEmpty()
  OTP_CODE_PEPPER!: string;

  @IsString()
  @IsNotEmpty()
  RATE_LIMIT_PEPPER!: string;

  @IsBoolean()
  TRUST_FORWARDED_ORIGIN!: boolean;

  @IsBoolean()
  FIXTURE_DELIVERY_ENABLED!: boolean;

  @IsIn(['fixture', 'unavailable'])
  DELIVERY_MODE!: DeliveryMode;

  @IsString()
  @IsNotEmpty()
  FIXTURE_INBOX_KEY!: string;

  @IsString()
  CORS_ORIGINS!: string;
}

function asBoolean(value: unknown): boolean {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    const normalized = value.trim().toLowerCase();
    if (normalized === 'true' || normalized === '1') return true;
    if (normalized === 'false' || normalized === '0' || normalized === '') {
      return false;
    }
  }
  return Boolean(value);
}

export function validateEnv(config: Record<string, unknown>) {
  const fixtureEnabled = asBoolean(config.FIXTURE_DELIVERY_ENABLED);
  const withDefaults: Record<string, unknown> = {
    ...config,
    TRUST_FORWARDED_ORIGIN: asBoolean(config.TRUST_FORWARDED_ORIGIN ?? false),
    FIXTURE_DELIVERY_ENABLED: fixtureEnabled,
    DELIVERY_MODE:
      config.DELIVERY_MODE ?? (fixtureEnabled ? 'fixture' : 'unavailable'),
  };

  const validated = plainToInstance(EnvironmentVariables, withDefaults, {
    enableImplicitConversion: true,
  });
  // Re-apply booleans after transform — string "false" must stay false.
  validated.TRUST_FORWARDED_ORIGIN = asBoolean(
    withDefaults.TRUST_FORWARDED_ORIGIN,
  );
  validated.FIXTURE_DELIVERY_ENABLED = asBoolean(
    withDefaults.FIXTURE_DELIVERY_ENABLED,
  );

  const errors = validateSync(validated, { skipMissingProperties: false });
  if (errors.length > 0) {
    throw new Error('Invalid backend configuration');
  }

  const env = validated.APP_ENVIRONMENT;
  if (!['dev', 'test', 'staging', 'prod'].includes(env)) {
    throw new Error('Unsupported APP_ENVIRONMENT');
  }

  if (validated.FIXTURE_DELIVERY_ENABLED && env !== 'dev' && env !== 'test') {
    throw new Error('Fixture delivery is not allowed outside dev/test');
  }

  if (
    validated.DELIVERY_MODE === 'fixture' &&
    env !== 'dev' &&
    env !== 'test'
  ) {
    throw new Error('DELIVERY_MODE=fixture is not allowed outside dev/test');
  }

  if (
    validated.DELIVERY_MODE === 'fixture' &&
    !validated.FIXTURE_DELIVERY_ENABLED
  ) {
    throw new Error(
      'DELIVERY_MODE=fixture requires FIXTURE_DELIVERY_ENABLED=true',
    );
  }

  // Staging/prod: fixture delivery is forbidden; DELIVERY_MODE must be
  // unavailable until a real adapter exists (fail-closed via Unavailable*).
  if (env === 'staging' || env === 'prod') {
    if (validated.FIXTURE_DELIVERY_ENABLED) {
      throw new Error('Fixture delivery is not allowed outside dev/test');
    }
    if (validated.DELIVERY_MODE !== 'unavailable') {
      throw new Error(
        'Staging/prod require DELIVERY_MODE=unavailable until real delivery adapters are configured',
      );
    }
  }

  if (env === 'prod') {
    if (
      validated.REFRESH_TOKEN_PEPPER.length < 32 ||
      validated.OTP_CODE_PEPPER.length < 32 ||
      validated.RATE_LIMIT_PEPPER.length < 32 ||
      validated.FIXTURE_INBOX_KEY.length < 32
    ) {
      throw new Error('Production secrets are too short');
    }
  }

  return validated;
}
