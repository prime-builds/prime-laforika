import { plainToInstance } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsString,
  Max,
  Min,
  validateSync,
} from 'class-validator';

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
  PASSWORD_PEPPER!: string;

  @IsBoolean()
  FIXTURE_DELIVERY_ENABLED!: boolean;

  @IsString()
  @IsNotEmpty()
  FIXTURE_INBOX_KEY!: string;

  @IsString()
  CORS_ORIGINS!: string;
}

export function validateEnv(config: Record<string, unknown>) {
  const validated = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });
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

  if (env === 'prod') {
    if (
      validated.REFRESH_TOKEN_PEPPER.length < 32 ||
      validated.OTP_CODE_PEPPER.length < 32 ||
      validated.PASSWORD_PEPPER.length < 32 ||
      validated.FIXTURE_INBOX_KEY.length < 32
    ) {
      throw new Error('Production secrets are too short');
    }
  }

  return validated;
}
